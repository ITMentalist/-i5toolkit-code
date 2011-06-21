/**
 * @file t003.as
 *
 * Recursive test of program-argument classes
 *
 * Principles:
 * - To decouple program objects with arguemnt-lists, pgm-argument
 *   class must be indepent with pgm-call classes.
 * - To support composite argument, arg class should support data
 *   structures in forms of trees.
 */

package {

    import flash.display.*;
    import as400.prototype.*;

    public class t003 extends Sprite {

        public function t003() {

            var argv:Vector.<ProgramArgument>
                = new Vector.<ProgramArgument>();

            // input argument, bin(4)
            var b:ProgramArgument = new ProgramArgument(new Bin2(), 11);
            b.name = "num_employee";  // name property is just for clarity
            b.value = 95;
            argv.push(b);

            // @todo 输出时, 是给 output/inout, 还是给全部
            // @todo 输入时, 要给全部; 那就都给全部吧

            // output argument, float(4)
            var f:ProgramArgument
                = new ProgramArgument(new Float4(),
                                      ProgramArgument.OUTPUT);
            f.name = "float";
            argv.push(f);

            // call program
            // pgm.callx(.., argv);
            //
            // @remark callx() 在处理参数时, 按 datatype and/or arg-direction 把 相应 read/write Function 压到对应的 vector 里, 在实际
            //         发送, 接收 时使用
            //         还是说, programArgument 类型自己有一对 read/write 方法?? i 觉得宁可不, 因为那样会把 协议的逻辑分散到 PGM-ARG 类型里去;
            //         而 i 的观点是, 逻辑集中在一个类型中, 是最有益于软件的维护的!

            // get output arg in argv @todo 当然, 这要放到被通知的 function 里
            var val:Object = argv[1].value;
            trace("value:", Number(val));

            trace("--------------------------------------------------");
        }

    }

}
