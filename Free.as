package {
    import flash.display.*;

    public class Free extends MovieClip {

        public var prop, index:Number;
        public var minesNearby:Number;

        public function Free(x, y, i:Number) {
            this.x = x;
            this.y = y;
            index = i;
            prop = Constant.FREE;
        }

        public function setMineNumber(num:Number) {
            minesNearby = num;

            if (minesNearby != 0) {
                gotoAndPlay(minesNearby + 1);
            }
        }

    }
}