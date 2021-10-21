
func ok(): return Result.new().set_ok(null)

func test_sanity():
    return ok()


func nice():
    yield(Engine.get_main_loop().create_timer(2.0), "timeout")
    print("nice finished")

    return "hello world"


func test_yield():

    print(Reflect.value_compare(BoardDeviceConfig.new().with_spec(BoardDeviceSpec.new().with_name("NICE")),
                                BoardDeviceConfig.new().with_spec(BoardDeviceSpec.new().with_name("NICE").with_atomic_u8("sss"))))

    

