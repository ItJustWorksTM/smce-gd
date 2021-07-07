/*
 *  MQTT.h
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

#ifndef MQTT_H
#define MQTT_H

#include <cstdint>
#include <cstring>
#include <functional>
#include <string>
#include <type_traits>

#include "Client.h"
#include "IPAddress.h"
#include "WString.h"

class MQTTClient;

using MQTTClientCallbackSimple = void (*)(String& topic, String& payload);
using MQTTClientCallbackAdvanced = void (*)(MQTTClient* client, const char* topic, const char* bytes, int length);
using MQTTClientCallbackSimpleFunction = std::function<std::remove_pointer_t<MQTTClientCallbackSimple>>;
using MQTTClientCallbackAdvancedFunction = std::function<std::remove_pointer_t<MQTTClientCallbackAdvanced>>;

struct SMCE__DLL_RT_API MQTTClientCallbacks {
    MQTTClient* client;
    MQTTClientCallbackSimple simple = nullptr;
    MQTTClientCallbackAdvanced advanced = nullptr;
#if _MSC_VER
#    pragma warning(push)
#    pragma warning(disable : 4251)
#endif
    MQTTClientCallbackSimpleFunction fsimple = nullptr;
    MQTTClientCallbackAdvancedFunction fadvanced = nullptr;
#if _MSC_VER
#    pragma warning(pop)
#endif
    explicit MQTTClientCallbacks(MQTTClient* client) noexcept : client{client} {}
};

class SMCE__DLL_RT_API MQTTClient {
    void* m_client = nullptr;
    bool m_clean_session = true;
    int m_keepalive = 60;
    int m_timeout = 120;
#if _MSC_VER
#    pragma warning(push)
#    pragma warning(disable : 4251)
#endif
    std::string m_host_uri = "localhost";
#if _MSC_VER
#    pragma warning(pop)
#endif
    std::uint16_t m_port = 1883;
    MQTTClientCallbacks m_callbacks{this};

  public:
    explicit MQTTClient(int bufSize = 128);

    ~MQTTClient();

    void begin(Client& client);
    inline void begin(const char* hostname, std::uint16_t port, Client& client) {
        this->begin(client);
        this->setHost(hostname, port);
    }
    inline void begin(IPAddress address, Client& client) { this->begin(address, 1883, client); }
    inline void begin(IPAddress address, std::uint16_t port, Client& client) {
        this->begin(client);
        this->setHost(address, port);
    }

    void onMessage(MQTTClientCallbackSimple cb);
    void onMessageAdvanced(MQTTClientCallbackAdvanced cb);
    void onMessage(MQTTClientCallbackSimpleFunction cb);
    void onMessageAdvanced(MQTTClientCallbackAdvancedFunction cb);

    // void setClockSource(MQTTClientClockSource cb);

    inline void setHost(const char* hostname) { this->setHost(hostname, 1883); }
    void setHost(const char* hostname, std::uint16_t port);
    inline void setHost(IPAddress address) { this->setHost(address, 1883); }
    void setHost(IPAddress _address, std::uint16_t port);

    void setWill(const char* topic, const char* payload = "", bool retained = false, int qos = 0);
    void clearWill();

    inline void setKeepAlive(int keep_alive) noexcept { m_keepalive = keep_alive; }
    inline void setCleanSession(bool clean_session) noexcept { m_clean_session = clean_session; }
    inline void setTimeout(int timeout) noexcept { m_timeout = timeout; }

    inline void setOptions(int _keepAlive, bool _cleanSession, int _timeout) {
        this->setKeepAlive(_keepAlive);
        this->setCleanSession(_cleanSession);
        this->setTimeout(_timeout);
    }

    inline bool connect(const char* clientId, bool skip = false) {
        return this->connect(clientId, nullptr, nullptr, skip);
    }
    inline bool connect(const char* clientId, const char* username, bool skip = false) {
        return this->connect(clientId, username, nullptr, skip);
    }
    bool connect(const char* clientID, const char* username, const char* password, bool skip = false);

    inline bool publish(const String& topic) { return this->publish(topic.c_str(), ""); }
    inline bool publish(const String& topic, const String& payload) {
        return this->publish(topic.c_str(), payload.c_str());
    }
    inline bool publish(const String& topic, const String& payload, bool retained, int qos) {
        return this->publish(topic.c_str(), payload.c_str(), retained, qos);
    }
    inline bool publish(const char* topic, const String& payload) { return this->publish(topic, payload.c_str()); }
    inline bool publish(const char* topic, const String& payload, bool retained, int qos) {
        return this->publish(topic, payload.c_str(), retained, qos);
    }
    inline bool publish(const char* topic, const char* payload = "", bool retained = false, int qos = 0) {
        return this->publish(topic, payload, (int)std::strlen(payload), retained, qos);
    }
    inline bool publish(const char* topic, const char* payload, int length) {
        return this->publish(topic, payload, length, false, 0);
    }
    bool publish(const char* topic, const char* payload, int length, bool retained, int qos);

    inline bool subscribe(const String& topic, int qos = 0) { return this->subscribe(topic.c_str(), qos); }
    bool subscribe(const char* topic, int qos = 0);

    inline bool unsubscribe(const String& topic) { return this->unsubscribe(topic.c_str()); }
    bool unsubscribe(const char* topic);

    bool loop();
    bool connected();

    bool disconnect();
};

#endif // MQTT_H
