extern(C):
nothrow:
@nogc:
@system:

version(LDC)
pragma(LDC_no_moduleinfo);

void io_hlt();

void Main()
{
    auto p = cast(char *) 0xa0000;
    for(int i = 0x0000; i < 0xffff; i++ )
    {
        p[i] = cast(char) (i % 16);
    }

    while(1) { io_hlt(); }
}
