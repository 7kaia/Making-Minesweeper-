package {
    import flash.display.*;

    public class Cover extends MovieClip {

        public var index:Number;
        public var isFlagged, isShowing:Boolean;

        public function Cover(x, y, i:Number) {
            this.x = x;
            this.y = y;
            index = i;
            isFlagged = false;
            isShowing = false;

        }

    }
}