/*
 *  MQTTClient.cxx
 *  Copyright 2020 ItJustWorksTM
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

#include <cassert>
#include <string>

#include "MQTT.h"

namespace SMCE__PAHO {
extern "C" {
#if __GNUC__
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
#elif _MSC_VER
#pragma warning(push)
#pragma warning(disable: 4201)
#endif
#include <MQTTClient.h>
#if __GNUC__
#pragma GCC diagnostic pop
#elif _MSC_VER
#pragma warning(pop)
#endif
}
}


extern "C"
int SMCE__mqtt_callback(void* context, char* topic_name, [[maybe_unused]] int topic_len, SMCE__PAHO::MQTTClient_message* message){
    const auto& callbacks = *reinterpret_cast<const MQTTClientCallbacks*>(context);
    if(callbacks.advanced)
        callbacks.advanced(callbacks.client, topic_name, static_cast<const char*>(message->payload), message->payloadlen);
    if(callbacks.simple)
        callbacks.simple(String{topic_name}, String{static_cast<const char*>(message->payload)});

    SMCE__PAHO::MQTTClient_free(topic_name);
    SMCE__PAHO::MQTTClient_freeMessage(&message);
    return 1;
}

MQTTClient::MQTTClient([[maybe_unused]] int bufSize) {}

MQTTClient::~MQTTClient() {
    SMCE__PAHO::MQTTClient_destroy(&m_client);
}

void MQTTClient::begin([[maybe_unused]] Client& client){}

void MQTTClient::onMessage(MQTTClientCallbackSimple cb){
    m_callbacks.simple = cb;

}
void MQTTClient::onMessageAdvanced(MQTTClientCallbackAdvanced cb){
    m_callbacks.advanced = cb;
}

void MQTTClient::setHost(const char* hostname, std::uint16_t port){
    m_host_uri = "tcp://";
    m_host_uri += hostname;
    m_host_uri += ':';
    m_host_uri += std::to_string(port);
}

void MQTTClient::setHost([[maybe_unused]] IPAddress address, [[maybe_unused]] std::uint16_t port){}

void MQTTClient::setWill([[maybe_unused]] const char* topic,
                         [[maybe_unused]] const char* payload,
                         [[maybe_unused]] bool retained,
                         [[maybe_unused]] int qos){}

void MQTTClient::clearWill(){}

bool MQTTClient::connect(const char* clientID, const char* username, const char* password, [[maybe_unused]] bool skip) {
    if(this->connected())
        this->disconnect();
    if(SMCE__PAHO::MQTTClient_create(&m_client, m_host_uri.c_str(), clientID, MQTTCLIENT_PERSISTENCE_NONE, nullptr) != MQTTCLIENT_SUCCESS) {
        m_client = nullptr;
        return false;
    }
    assert(SMCE__PAHO::MQTTClient_setCallbacks(m_client, &m_callbacks, nullptr, SMCE__mqtt_callback, nullptr) == MQTTCLIENT_SUCCESS);
    SMCE__PAHO::MQTTClient_connectOptions opts = MQTTClient_connectOptions_initializer;
    opts.username = username;
    opts.password = password;
    opts.cleansession = m_clean_session;
    const int res = SMCE__PAHO::MQTTClient_connect(m_client, &opts);
    return res == MQTTCLIENT_SUCCESS;
}

bool MQTTClient::publish(const char* topic, const char* payload, int length, bool retained, int qos) {
    return SMCE__PAHO::MQTTClient_publish(m_client, topic, length, payload, qos, retained, nullptr) == MQTTCLIENT_SUCCESS;
}

bool MQTTClient::subscribe(const char* topic, int qos) {
    return SMCE__PAHO::MQTTClient_subscribe(m_client, topic, qos) == MQTTCLIENT_SUCCESS;
}

bool MQTTClient::unsubscribe(const char* topic) {
    return SMCE__PAHO::MQTTClient_unsubscribe(m_client, topic) == MQTTCLIENT_SUCCESS;
}

bool MQTTClient::loop(){
    SMCE__PAHO::MQTTClient_yield();
    return true;
}
bool MQTTClient::connected() {
    return m_client && SMCE__PAHO::MQTTClient_isConnected(m_client);
}
bool MQTTClient::disconnect() {
    return SMCE__PAHO::MQTTClient_disconnect(m_client, m_timeout) == MQTTCLIENT_SUCCESS;
}
