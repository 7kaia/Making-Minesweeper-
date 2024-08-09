package {
    import flash.display.*;
    import flash.events.*;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    

    public class Controller extends MovieClip {
        private var spaces:Array;
        private var coversAndFlags:Array;

        private var mouseCoord = -1;
        private var numOfMines = 0;
        private var numVisibleCovers = Constant.NUMSPACES;
        private var numOfFlags:Number = 0;
        private var flagText:TextField;

        private var timerText: TextField; 
        private var timer:Timer;
        private var time = 0;

        private var textFormat:TextFormat;

        private var freePercent = 80; //possibility of an free being on the board

        private var isGameOver:Boolean = true;

        public function Controller() {
            clearStage();
            makeCovers();
            initializeTextFormat();
            initializeTimerText();
            
            playButton.addEventListener(MouseEvent.CLICK, reset);
            
            timer = new Timer(1000);
        }

        private function clearStage() {
            while (this.numChildren > 0) {
                this.removeChildAt(0);
            }

            spaces = [];
            coversAndFlags = [];
        }

        private function reset(event:MouseEvent) {
            clearStage();
            makeCovers();

            numOfMines = 0;
            numVisibleCovers = Constant.NUMSPACES;
            numOfFlags = 0;

            initializeTimerText();
            time = 0;
            timer.reset();
        }

        private function loseGame() {
            numVisibleCovers = -1;
            addChild(lose);
            addChild(playButton);

            for (var i = 0; i < coversAndFlags.length; i++) {
                var cover:Cover = coversAndFlags[i];
                if (stage.contains(cover)) {
                    if (spaces[i].prop == Constant.MINE && !cover.isFlagged) { //reveal mine
                        removeChild(cover);
                    } else if (spaces[i].prop == Constant.FREE && cover.isFlagged) { //put flag on wrong spot
                        cover.gotoAndPlay(3);
                    } 
                }
                isGameOver = true;
            }
        }


        private function winGame() {
            addChild(win);
            addChild(playButton);

            isGameOver = true;
        }


        private function makeCovers() {
            var x:Number = Constant.MARGIN + Constant.WIDTH;
            var y:Number = Constant.MARGIN + Constant.WIDTH;

            var index:Number = 0;

            for (var r = 0; r < Constant.ROWS; r++) {
                for (var c = 0; c < Constant.COLS; c++) {
                    var cover:Cover = new Cover(x, y, index);
                    coversAndFlags.push(cover);
                    addChild(cover);
                    cover.addEventListener(MouseEvent.MOUSE_OVER, hover(cover));
                    cover.addEventListener(MouseEvent.MOUSE_OUT, out);

                    x += Constant.WIDTH;
                    index++;
                }
                x = Constant.MARGIN + Constant.WIDTH;
                y += Constant.WIDTH;
            }
        }


        private function makeBoard(index:Number) {
            
            var possibleIndices = [];
            possibleIndices.push(index);
            var up = index - Constant.COLS;
            var down = index + Constant.COLS;

            if (up < 0) { // at top edge
                possibleIndices.push(down);

                if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                    possibleIndices.push(index + 1);
                    possibleIndices.push(down + 1);
                } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                    possibleIndices.push(index - 1);
                    possibleIndices.push(down - 1);
                } else { //at middle horizontally
                    possibleIndices.push(index + 1);
                    possibleIndices.push(down + 1);
                    possibleIndices.push(index - 1);
                    possibleIndices.push(down - 1);
                }

            } else if (down >= Constant.NUMSPACES) { //at bottom edge
                possibleIndices.push(up);

                if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                    possibleIndices.push(up + 1);
                    possibleIndices.push(index + 1);
                } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                    possibleIndices.push(up - 1);
                    possibleIndices.push(index - 1);
                } else { //at middle horizontally
                    possibleIndices.push(up + 1);
                    possibleIndices.push(index + 1);
                    possibleIndices.push(up - 1);
                    possibleIndices.push(index - 1);
                }
            } else { //at middle vertically
                possibleIndices.push(up);
                possibleIndices.push(down);

                if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                    possibleIndices.push(up + 1);
                    possibleIndices.push(index + 1);
                    possibleIndices.push(down + 1);
                } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                    possibleIndices.push(up - 1);
                    possibleIndices.push(index - 1);
                    possibleIndices.push(down - 1);
                } else { //at middle horizontally
                    possibleIndices.push(up + 1);
                    possibleIndices.push(index + 1);
                    possibleIndices.push(down + 1);
                    possibleIndices.push(up - 1);
                    possibleIndices.push(index - 1);
                    possibleIndices.push(down - 1);
                }
            }

            var x:Number = Constant.MARGIN + Constant.WIDTH;
            var y:Number = Constant.MARGIN + Constant.WIDTH;

            var index:Number = 0;

            for (var r = 0; r < Constant.ROWS; r++) {
                for (var c = 0; c < Constant.COLS; c++) {

                    if (possibleIndices.indexOf(index) != -1) { 
                        var fr:Free = new Free(x, y, index);
                        spaces.push(fr);
                        addChild(fr);
                    } else {
                        var num:Number = Math.random() * 100 + 1;

                        if (num <= freePercent) {
                            var free:Free = new Free(x, y, index);
                            spaces.push(free);
                            addChild(free);
                        } else {
                            var mine:Mine = new Mine(x, y, index);
                            spaces.push(mine);
                            addChild(mine);
                            numOfMines++;
                        }
                    }

                    addChild(coversAndFlags[index]);

                    x += Constant.WIDTH;
                    index++;
                }
                x = Constant.MARGIN + Constant.WIDTH;
                y += Constant.WIDTH;
            }
            assignMineNumbers();
            initializeFlagText();
            
            timer.addEventListener(TimerEvent.TIMER, runTimer);
            timer.start();
            
            isGameOver = false;
        }

        private function initializeTimerText() {
            timerText = new TextField();
            timerText.x = 825;
            timerText.y = 475;
            timerText.height = 250;
            timerText.width = 300;
            timerText.wordWrap = true;

            //timerText.text = "Time - 00:00";
            timerText.text = "Time - 00:00";
            timerText.setTextFormat(textFormat);

            addChild(timerText);
        }


        private function initializeFlagText() {
            flagText = new TextField();
            numOfFlags = numOfMines;
            flagText.x = 825;
            flagText.y = 375;
            flagText.height = 250;
            flagText.width = 300;
            flagText.wordWrap = true;

            flagText.text = "Number of flags: " + numOfFlags;
            flagText.setTextFormat(textFormat);
            
            addChild(flagText);
        }


        private function updateFlagText() {
            flagText.text = "Number of flags: " + numOfFlags;

            flagText.setTextFormat(textFormat);
        }

        private function initializeTextFormat() {
            textFormat = new TextFormat();
            textFormat.bold = true;
            textFormat.font = "Consolas";
            textFormat.align = "center";
            textFormat.size = 32;
        }


        private function runTimer(event:TimerEvent) {
            time++;

            var stringAdd = "";

            var min:uint = (int)(time / 60);
            var seconds:uint = time % 60;

            if (min < 10) {
                stringAdd += "0";
            }
            stringAdd += min + ":";

            if (seconds < 10) {
                stringAdd += 0;
            }
            stringAdd += seconds;

            timerText.text = "Time - " + stringAdd;
            timerText.setTextFormat(textFormat);
        }
        

        private function assignMineNumbers() {

            var possibleIndices = [];

            for (var index = 0; index < Constant.NUMSPACES; index++) {

                if (spaces[index].prop == Constant.FREE) {
                    var up = index - Constant.COLS;
                    var down = index + Constant.COLS;

                    if (up < 0) { // at top edge
                        possibleIndices.push(down);

                        if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                            possibleIndices.push(index + 1);
                            possibleIndices.push(down + 1);
                        } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                            possibleIndices.push(index - 1);
                            possibleIndices.push(down - 1);
                        } else { //at middle horizontally
                            possibleIndices.push(index + 1);
                            possibleIndices.push(down + 1);
                            possibleIndices.push(index - 1);
                            possibleIndices.push(down - 1);
                        }

                    } else if (down >= Constant.NUMSPACES) { //at bottom edge
                        possibleIndices.push(up);

                        if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                            possibleIndices.push(up + 1);
                            possibleIndices.push(index + 1);
                        } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                            possibleIndices.push(up - 1);
                            possibleIndices.push(index - 1);
                        } else { //at middle horizontally
                            possibleIndices.push(up + 1);
                            possibleIndices.push(index + 1);
                            possibleIndices.push(up - 1);
                            possibleIndices.push(index - 1);
                        }
                    } else { //at middle vertically
                        possibleIndices.push(up);
                        possibleIndices.push(down);

                        if ((index - 1) < 0 || (index - 1) % Constant.COLS == Constant.COLS - 1) { //at left edge
                            possibleIndices.push(up + 1);
                            possibleIndices.push(index + 1);
                            possibleIndices.push(down + 1);
                        } else if ((index + 1) >= Constant.NUMSPACES || (index + 1) % Constant.COLS == 0) { //at right edge
                            possibleIndices.push(up - 1);
                            possibleIndices.push(index - 1);
                            possibleIndices.push(down - 1);
                        } else { //at middle horizontally
                            possibleIndices.push(up + 1);
                            possibleIndices.push(index + 1);
                            possibleIndices.push(down + 1);
                            possibleIndices.push(up - 1);
                            possibleIndices.push(index - 1);
                            possibleIndices.push(down - 1);
                        }
                    }

                    var count:Number = 0;
                    for (var i = 0; i < possibleIndices.length; i++) { // 3 <= possibleIndices.length <= 8
                        if (spaces[possibleIndices[i]].prop == Constant.MINE) {
                            count++;
                        }
                    }
                    spaces[index].setMineNumber(count);
                    possibleIndices = [];
                }
            }
        }


        private function hover(cover:Cover) {
            return function(event:MouseEvent) { 
                mouseCoord = cover.index;
                cover.addEventListener(MouseEvent.MOUSE_DOWN, click);
                cover.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, flag);
            }
        }


        private function out(event:MouseEvent) { mouseCoord = -1; }

        private function click(event:MouseEvent) {
            if (mouseCoord != -1) {

                var cover:Cover = coversAndFlags[mouseCoord];
                if (stage.contains(cover) && !cover.isFlagged) { //if block is covered and block isn't flagged
                    if (numVisibleCovers == Constant.NUMSPACES) {
                        makeBoard(cover.index);
                        removeChild(cover);
                        numVisibleCovers--;
                        doMagic(cover.index);
                    } else if (!isGameOver) {
                        removeChild(cover);
                        if (spaces[mouseCoord].prop == Constant.MINE) { //If the player clicks a mine
                            loseGame();
                            //timer.removeEventListener(TimerEvent.TIMER, runTimer);
                            timer.stop();
                        } else if (spaces[mouseCoord].minesNearby == 0) { //if the player clicks a space with no mines nearby
                            doMagic(cover.index);
                        }
                        numVisibleCovers--;
                        if (numVisibleCovers == numOfMines) {
                            winGame();
                            timer.stop();
                        }
                    }
                }
            }
        }


        private function flag(event:MouseEvent) {
            if (mouseCoord != -1 && !isGameOver) {
                var cover:Cover = coversAndFlags[mouseCoord];
                if (!cover.isFlagged && numOfFlags > 0) { //place a flag
                    cover.gotoAndPlay(2);
                    cover.isFlagged = true;
                    numOfFlags--;
                } else { //remove an already placed flag
                    cover.gotoAndPlay(1); 
                    cover.isFlagged = false;
                    numOfFlags++;
                }
                updateFlagText();
            }
        }


        private function doMagic(i:Number) {

            var stack:Array = [];
            var pointer = spaces[i];
            var index = i;

            while (true) {
                var possibleIndices = [];
                var possibleCorners = [];

                if (contains(coversAndFlags[index]) && !coversAndFlags[index].isFlagged) {
                    removeChild(coversAndFlags[index]);
                    numVisibleCovers--;
                }

                var up = index - Constant.COLS;
                var down = index + Constant.COLS;

                if (up >= 0) {
                    if (up - 1 >= 0 && (up - 1) % Constant.COLS != Constant.COLS - 1 && spaces[up - 1].prop == Constant.FREE && contains(coversAndFlags[up - 1]) && spaces[up - 1].minesNearby > 0) {
                        possibleCorners.push(up - 1); //top left
                    }

                    if (up + 1 < Constant.NUMSPACES && (up + 1) % Constant.COLS != 0 && spaces[up + 1].prop == Constant.FREE && contains(coversAndFlags[up + 1]) && spaces[up + 1].minesNearby > 0) {
                        possibleCorners.push(up + 1); //top right
                    }
                }

                if (down < Constant.NUMSPACES) {
                    if (down - 1 >= 0 && (down - 1) % Constant.COLS != Constant.COLS - 1 && spaces[down - 1].prop == Constant.FREE && contains(coversAndFlags[down - 1]) && spaces[down - 1].minesNearby > 0) {
                        possibleCorners.push(down - 1); //bottom left
                    }

                    if (down + 1 < Constant.NUMSPACES && (down + 1) % Constant.COLS != 0 && spaces[down + 1].prop == Constant.FREE && contains(coversAndFlags[down + 1]) && spaces[down + 1].minesNearby > 0) {
                        possibleCorners.push(down + 1); //bottom right
                    }
                }

                for (var i = 0; i < possibleCorners.length; i++) {
                    if (spaces[possibleCorners[i]].minesNearby > 0 && !coversAndFlags[possibleCorners[i]].isFlagged) {
                        removeChild(coversAndFlags[possibleCorners[i]]);
                        numVisibleCovers--;
                    }
                }

                
                if (spaces[index].prop == Constant.FREE && spaces[index].minesNearby == 0) { 
                    
                    if (up >= 0 && spaces[up].prop == Constant.FREE && contains(coversAndFlags[up])) { //up
                        possibleIndices.push(up);
                    }

                    if (down < Constant.NUMSPACES && spaces[down].prop == Constant.FREE && contains(coversAndFlags[down])) { //down
                        possibleIndices.push(down);
                    }

                    if ((index - 1) >= 0 && (index - 1) % Constant.COLS != Constant.COLS - 1 && spaces[index - 1].prop == Constant.FREE && contains(coversAndFlags[index - 1])) { //left
                        possibleIndices.push(index - 1);
                    } 
                    
                    if ((index + 1) < Constant.NUMSPACES && (index + 1) % Constant.COLS != 0 && spaces[index + 1].prop == Constant.FREE && contains(coversAndFlags[index + 1])) { //right
                        possibleIndices.push(index + 1);
                    }
                }
                

                if (possibleIndices.length > 0) {
                    stack.push(pointer);
                    pointer = spaces[possibleIndices.pop()];
                    index = pointer.index;
                } else if (stack.length == 0) {
                    break;
                } else {
                    pointer = stack.pop();
                    index = pointer.index;
                }
            }
        }

    }
}