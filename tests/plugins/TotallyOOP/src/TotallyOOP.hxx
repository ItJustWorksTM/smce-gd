
#ifndef GODOT_SMCE_UDDPROVIDER_HXX
#define GODOT_SMCE_UDDPROVIDER_HXX

class _TotallyOOP;

class TotallyOOP {

    const _TotallyOOP* device;

  public:
    TotallyOOP(int identifier);

    int read();

    void write(int value);
};

#endif