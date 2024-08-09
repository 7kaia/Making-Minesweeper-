package {
    import flash.display.*;

    public class Mine extends MovieClip {

        public var prop:Number;
        public var index:Number;

        public function Mine(x, y, i:Number) {
            this.x = x;
            this.y = y;
            index = i;
            prop = Constant.MINE;
        }

    }
}