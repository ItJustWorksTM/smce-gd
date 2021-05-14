/*
 *  MQTTClient.cxx
 *  Copyright 2020-2021 ItJustWorksTM
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "MQTT.h"

#include <mosquitto.h>

using Mosquitto = struct mosquitto;
using MosquittoMessage = struct mosquitto_message;

static int mosquitto_lib_init_res = []() noexcept {
  const int res = mosquitto_lib_init();
  if(res == MOSQ_ERR_SUCCESS)
      std::atexit(+[]{ mosquitto_lib_cleanup(); });
  else
      std::fputs("Mosquitto init failed", stderr);
  return res;
}();

static void mqtt_message_callback(Mosquitto*, void* context, const MosquittoMessage* message){
    const auto& callbacks = *reinterpret_cast<const MQTTClientCallbacks*>(context);
    // Disclaimer: I do not like this ordering at all, but we must replicate the behaviour of arduino-mqtt
    if(callbacks.advanced)
        return (void)callbacks.advanced(callbacks.client, message->topic, static_cast<const char*>(message->payload), message->payloadlen);
    if(callbacks.fadvanced)
        return (void)callbacks.fadvanced(callbacks.client, message->topic, static_cast<const char*>(message->payload), message->payloadlen);
    if(callbacks.simple || callbacks.fsimple) {
        String topic = message->topic;
        String msg = String{String::internal_tag, static_cast<const char*>(message->payload), static_cast<std::size_t>(message->payloadlen)};
        if(callbacks.fsimple)
            return (void)callbacks.fsimple(topic, msg);
        if(callbacks.simple)
            return (void)callbacks.simple(topic, msg);
    }
}

MQTTClient::MQTTClient([[maybe_unused]] int bufSize) {}

MQTTClient::~MQTTClient() {
    if(m_client)
        mosquitto_destroy(static_cast<Mosquitto*>(m_client));
}

void MQTTClient::begin([[maybe_unused]] Client& client){}

void MQTTClient::onMessage(MQTTClientCallbackSimple cb){
    m_callbacks.simple = cb;

}
void MQTTClient::onMessageAdvanced(MQTTClientCallbackAdvanced cb){
    m_callbacks.advanced = cb;
}
void MQTTClient::onMessage(MQTTClientCallbackSimpleFunction cb) {
    m_callbacks.fsimple = std::move(cb);
}
void MQTTClient::onMessageAdvanced(MQTTClientCallbackAdvancedFunction cb) {
    m_callbacks.fadvanced = std::move(cb);
}

void MQTTClient::setHost(const char* hostname, std::uint16_t port){
    m_host_uri = hostname;
    m_port = port;
}

void MQTTClient::setHost([[maybe_unused]] IPAddress address, [[maybe_unused]] std::uint16_t port){}

void MQTTClient::setWill(const char* topic, const char* payload, bool retained, int qos){
    mosquitto_will_set(static_cast<Mosquitto*>(m_client), topic, static_cast<int>(std::strlen(payload)), payload, qos, retained);
}

void MQTTClient::clearWill(){
    mosquitto_will_clear(static_cast<Mosquitto*>(m_client));
}

bool MQTTClient::connect(const char* clientID, const char* username, const char* password, [[maybe_unused]] bool skip) {
    if(this->connected())
        this->disconnect();

    if(m_client)
        mosquitto_reinitialise(static_cast<Mosquitto*>(m_client), clientID, m_clean_session, &m_callbacks);
    else {
        m_client = mosquitto_new(clientID, m_clean_session, &m_callbacks);
        if(!m_client)
            return false;
    }
    if(mosquitto_username_pw_set(static_cast<Mosquitto*>(m_client), username, password) != MOSQ_ERR_SUCCESS)
        return false;

    mosquitto_message_callback_set(static_cast<Mosquitto*>(m_client), mqtt_message_callback);

    const int res = mosquitto_connect(static_cast<Mosquitto*>(m_client), m_host_uri.c_str(), m_port, m_keepalive);
    switch (res) {
    case MOSQ_ERR_SUCCESS:
        return true;
    case MOSQ_ERR_INVAL:
        std::fprintf(stderr, "MQTTClient::connect failed: invalid arguments in mosquitto_connect(%p, %s, %d, %d)", m_client, m_host_uri.c_str(), m_port, 60);
        break;
    case MOSQ_ERR_ERRNO:
        ::perror("MQTTClient::connect failed");
        break;
    default:
        std::fprintf(stderr, "MQTTClient::connect failed: mosquitto_connect unknown return code %d", res);
    }
    return false;
}

bool MQTTClient::publish(const char* topic, const char* payload, int length, bool retained, int qos) {
    return mosquitto_publish(static_cast<Mosquitto*>(m_client), nullptr, topic, length, payload, qos, retained) == MOSQ_ERR_SUCCESS;
}

bool MQTTClient::subscribe(const char* topic, int qos) {
    return mosquitto_subscribe(static_cast<Mosquitto*>(m_client), nullptr, topic, qos) == MOSQ_ERR_SUCCESS;
}

bool MQTTClient::unsubscribe(const char* topic) {
    return mosquitto_unsubscribe(static_cast<Mosquitto*>(m_client), nullptr, topic) == MOSQ_ERR_SUCCESS;
}

bool MQTTClient::loop(){
    return mosquitto_loop(static_cast<Mosquitto*>(m_client), 0, 1024) == MOSQ_ERR_SUCCESS;
}
bool MQTTClient::connected() {
    return m_client && mosquitto_socket(static_cast<Mosquitto*>(m_client)) != -1;
}
bool MQTTClient::disconnect() {
    return mosquitto_disconnect(static_cast<Mosquitto*>(m_client)) == MOSQ_ERR_SUCCESS;
}
