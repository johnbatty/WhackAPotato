package
{
    import cocos2d.Cocos2DGame;
    import cocos2d.CCSprite;
    import cocos2d.CCPoint;
    import cocos2d.ScaleMode;
    import cocos2d.Cocos2D;

    import UI.Label;

    import Loom.Animation.Tween;
    import Loom.Animation.EaseType;
    import Loom.Platform.Timer;

    import Loom.Platform.LoomKey;

    import CocosDenshion.SimpleAudioEngine;

    import System.Process;

    public class WhackAMole extends Cocos2DGame
    {
        protected const GAME_TIME_SECS = 30;
        protected const MAX_STRIKES = 3;
        protected const HIT_POINTS = 100;
        protected const MISS_POINTS = 5;

        protected var timer:Timer;
        protected var moles:Vector.<CCSprite>;
        protected var moleStates:Vector.<Boolean>;
        protected var scores:Vector.<Label>;
        protected var misses:Vector.<Label>;
        protected var waitTime:Number;
        protected var totalScore:Label;
        protected var total:Number;
        protected var strikes:Number;
        protected var retryButton:CCSprite;
        protected var timeLabel:Label;
        protected var gameTimer:Timer;
        protected var timeLastHealthWarning:Number;

        override public function run():void
        {
            super.run();

            layer.scaleMode = ScaleMode.LETTERBOX;

            waitTime = 2.5;
            strikes = 0;
            timeLastHealthWarning = 0;

            var ground = CCSprite.createFromFile("assets/background/bg_dirt.png");
            ground.x = layer.designWidth/2;
            ground.y = layer.designHeight/2;
            layer.addChild(ground);

            var top = CCSprite.createFromFile("assets/foreground/grass_upper.png");
            top.x = layer.designWidth/2;
            top.y = layer.designHeight/2;
            top.setAnchorPoint(new CCPoint(0.5,0));
            top.setScale(0.5);
            layer.addChild(top);

            var mole1 = CCSprite.createFromFile("assets/sprites/mole_1.png");
            mole1.x = 65;
            mole1.y = 85;
            mole1.setScale(0.5);
            layer.addChild(mole1);
            mole1.onTouchBegan = function() {
                whackMole(mole1);
            }

            var mole2 = CCSprite.createFromFile("assets/sprites/mole_2.png");
            mole2.x = 240;
            mole2.y = 85;
            mole2.setScale(0.5);
            layer.addChild(mole2);
            mole2.onTouchBegan = function() {
                whackMole(mole2);
            }

            var mole3 = CCSprite.createFromFile("assets/sprites/mole_3.png");
            mole3.x = 410;
            mole3.y = 85;
            mole3.setScale(0.5);
            layer.addChild(mole3);
            mole3.onTouchBegan = function() {
                whackMole(mole3);
            }

            moles = [mole1, mole2, mole3];
            moleStates = [false, false, false];

            var bottom = CCSprite.createFromFile("assets/foreground/grass_lower.png");
            bottom.x = layer.designWidth/2;
            bottom.y = layer.designHeight/2;
            bottom.setAnchorPoint(new CCPoint(0.5,1));
            bottom.setScale(0.5); 
            layer.addChild(bottom);

            total = 0;
            totalScore = new Label("assets/fonts/Curse-hd.fnt");
            totalScore.text = "0";
            totalScore.x = layer.designWidth/2;
            totalScore.y = 80;
            totalScore.scale = 0.75;
            layer.addChild(totalScore);

            retryButton = CCSprite.createFromFile("assets/labels/gameover.png");
            retryButton.retain();
            retryButton.x = layer.designWidth/2;
            retryButton.y = 250;
            retryButton.scale = 0.5;
            retryButton.onTouchEnded = resetGame;

            timeLabel = new Label("assets/fonts/Curse-hd.fnt");
            timeLabel.text = "30";
            timeLabel.x = 445;
            timeLabel.y = 295;
            timeLabel.scale = 0.5;
            layer.addChild(timeLabel);

            gameTimer = new Timer(30000);
            gameTimer.onComplete = endGame;
            gameTimer.start();

            timer = new Timer(1000);
            timer.onComplete = onTimerComplete;
            timer.start();

            //Cocos2D.toggleFullscreen();

            layer.onTouchBegan = onMiss;

            // Enable keyboard/keypad callbacks and register ours.
            layer.setKeypadEnabled(true);
            layer.onKeyDown += handleKeyDown;

            createScoreLabels();
        }

        protected function handleKeyDown(keycode:int):void
        {
            if (keycode == LoomKey.A) {
                whackMole(moles[0]);
            }
            
            if (keycode == LoomKey.S) {
                whackMole(moles[1]);            
            }
            
            if (keycode == LoomKey.D) {
                whackMole(moles[2]);            
            }
            
            if(keycode == LoomKey.SPACEBAR) {
                endGame();
                resetGame();
            }

            if (keycode == LoomKey.F) {
                Cocos2D.toggleFullscreen();
            }

            if (keycode == LoomKey.ESCAPE) {
                Process.exit(0)
            }
        }

        override public function onTick()
        {
            var timeLeftSecs = GAME_TIME_SECS - Math.round(gameTimer.elapsed/1000)
            timeLabel.text = timeLeftSecs.toString();

            // Health check...
            var strikesLeft = MAX_STRIKES - strikes;

            if ((timeLeftSecs < 5) || (strikesLeft <= 1)) {
                if (timeLeftSecs != timeLastHealthWarning) {
                    SimpleAudioEngine.sharedEngine().playEffect("assets/sounds/health.wav");
                    timeLastHealthWarning = timeLeftSecs;                
                }
            }
        }

        protected function createScoreLabels()
        {
            // create a pool a score labels to pull from
            scores = new Vector.<Label>();
            misses = new Vector.<Label>();
            for (var i = 0; i<4; i++) {
                var score = new Label("assets/fonts/Curse-hd.fnt");
                score.text = "+100";
                score.scale = 0.5;
                score.y = 400;
                scores.push(score);
                layer.addChild(score);

                var miss = new Label("assets/fonts/Red-hd.fnt");
                miss.text = "miss";
                miss.y = 400;
                misses.push(miss);
                layer.addChild(miss);
            }
        }

        protected function getAvailableScoreLabel():Label
        {
            for (var i = 0; i < scores.length; i++) {
                var score = scores[i];
                if (!Tween.isTweening(score))
                    return score;
            }

            // default, return the first one
            Tween.killTweensOf(scores[0]);
            return scores[0];
        }

        protected function getAvailableMissLabel():Label
        {
            for (var i = 0; i < misses.length; i++) {
                var miss = misses[i];
                if (!Tween.isTweening(miss)) {
                    return miss;
                }
            }

            // default, return the first one
            Tween.killTweensOf(misses[0]);
            return misses[0];
        }

        protected function onTimerComplete(timer:Timer)
        {
            for (var i = 0; i<moles.length; i++)
            {
                if (Math.floor(Math.random() * 4) == 0)
                {
                    var mole = moles[i];

                    if (moleStates[i] == true) {
                        moleStates[i] = false;
                        //mole.setTextureFile("assets/sprites/mole_1.png");
                    }

                    if (!Tween.isTweening(mole)) {
                        Tween.to(mole, 0.5, {"y": 75+mole.getContentSize().height/2, "ease": EaseType.EASE_OUT});
                        Tween.to(mole, 0.3, {"y": 75, "ease": EaseType.EASE_OUT, "delay": 0.5+waitTime});
                    }
                }
            }

            // play the timer again
            timer.start();
        }

        protected function whackMole(mole:CCSprite)
        {
            if (strikes == 3) 
                return;
 
            var index = moles.indexOf(mole);
            if (moleStates[index] == false && (mole.y > 90)) {
                onHit(index);
            }
            else
            {
                onMiss(index, mole.x, 200);
            }
        }

        protected function updateTotal(points:Number)
        {
            total += points;
            totalScore.text = total.toString();        
        }

        protected function onHit(index:Number)
        {
            var mole = moles[index];

            SimpleAudioEngine.sharedEngine().playEffect("assets/sounds/hit.wav");

            // increase the difficulty as we get more moles
            waitTime *= 0.9;
            timer.delay *= 0.9;

            // update our whacked state
            moleStates[index] = true;

            // animate a score
            var score = getAvailableScoreLabel();
            score.x = mole.x;
            score.y = 275;
            score.scale = 0;

            updateTotal(HIT_POINTS);

            Tween.to(score, 0.3, {"scale": 0.5, "ease": EaseType.EASE_OUT_BACK})
            Tween.to(score, 0.3, {"y": 400, "ease": EaseType.EASE_IN_BACK, "delay": 0.3});

            Tween.killTweensOf(mole);
            //mole.setTextureFile("assets/sprites/mole_thump4.png");
            Tween.to(mole, 0.3, {"y": 85, "ease": EaseType.EASE_OUT, "delay": 0.1}).onComplete;
        }

        protected function onMiss(index:Number, x:Number, y:Number)
        {
            if (strikes == MAX_STRIKES) {
                return;
            }
            
            SimpleAudioEngine.sharedEngine().playEffect("assets/sounds/miss.wav");
            
            // Disable strike counter...
            //strikes++;

            updateTotal(-MISS_POINTS);

            var miss = getAvailableMissLabel();
            miss.x = x;
            miss.y = y;
            miss.scale = 0;

            Tween.to(miss, 0.3, {"scale": 0.5, "ease": EaseType.EASE_OUT_BACK})
            Tween.to(miss, 0.3, {"y": 400, "ease": EaseType.EASE_IN_BACK, "delay": 0.3});

            if (strikes == MAX_STRIKES) {
                endGame();
            }
        }

        protected function endGame(t:Timer=null)
        {
            strikes = MAX_STRIKES;
            timer.stop();
            gameTimer.stop();

            if (timeLabel.getParent() != null) {
                layer.removeChild(timeLabel);            
            }

            if (retryButton.getParent() == null) {
                layer.addChild(retryButton);            
            }
        }

        protected function resetGame()
        {
            layer.addChild(timeLabel);
            strikes = 0;
            total = 0;
            totalScore.text = "0";
            timer.start();
            gameTimer.start();
            layer.removeChild(retryButton);
            waitTime = 0.5;
            timer.delay = 1000;
        }
    }
}
