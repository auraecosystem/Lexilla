.assembly extern mscorlib {}
.assembly HelloWorld {}
.module HelloWorld.exe

.method static void Main() cil managed
{
    .entrypoint
    .maxstack 1

    // Push string onto the evaluation stack
    ldstr "Hello, IL Assembly!"

    // Call System.Console.WriteLine(string)
    call void [mscorlib]System.Console::WriteLine(string)

    // Return from Main
    ret
}
