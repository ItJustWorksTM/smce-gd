
#include "TotallyOOP.hxx"
#include "_TotallyOOP.hpp"

TotallyOOP::TotallyOOP(int identifier) {
    for (auto& obj : _TotallyOOP::objects) {
        obj.value.store(2);
        if (obj.id == identifier) {
            device = &obj;
            return;
        }
    }
    throw -1;
}

int TotallyOOP::read() { return device->value.load(); }
void TotallyOOP::write(int value) { return device->value.store(value); }
