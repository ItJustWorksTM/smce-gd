

class Enum:
    pass
class A: extends Enum
class B: extends Enum
class C:
    extends Enum
    var message = "hello world"


func test_deduct():

    var en = C.new()

    en.message = "fu"

    match en:
        A:
            pass
        B:
            pass
        C:
            print(en.mssage)
        _:
            print("broken")
    print("huh")
    pass
