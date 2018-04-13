<scroll style="height:{opts.height}px;" ref="scroll">
    <div style="height:{opts.height}px;" ref="scrollParts" class="scroll-parts">
        <div class="scroll-body" ref="scrollBody">
            <div class="scroll-contents" ref="scrollContents">
                <yield />
            </div>
        </div>
        <div ref="scrollBarArea" class="scroll-bar-area">
            <div class="scroll-bar" ref="scrollBar"></div>
        </div>
    </div>

    <script>
        var self = this;
        self.positionState = "no-scroll";
        self.barHeight = 100;

        self.on("mount", function(){
            // スクロールパーツの監視を開始
            var contents = self.refs.scrollBody;
            if(contents instanceof Array) return;
            mutationObserver.observe(self.refs.scrollContents, mutationConfig);

            // 初回のスクロールバーサイズ調整
            setScrollBarSize(contents);
            setScrollBarPosition(contents);
            // スクロール状態を監視
            contents.addEventListener("scroll", function () {
                var body = self.refs.scrollBody;
                setScrollBarPosition(body);
            });
            self.update();
        });

        self.on("update", function () {
            updateScrollParts();
        });

        // スクロールするコンテンツに変更が発生したときのみイベントを発火させる設定
        var mutationConfig = { attributes: true, childList: true, characterData: true, subtree: true };
        var mutationObserver = new MutationObserver(function(){
            updateScrollParts();
        });

        // スクロールバーのサイズを変更する
        function setScrollBarSize(body) {
            if (isUndefined(body)) return;
            if (isUndefined(self.refs.scrollBody) || isUndefined(self.refs.scrollContents)) return;

            var scrollBarHeight = 100;
            // 0除算を防ぐ
            if (self.refs.scrollContents.offsetHeight !== 0)
                scrollBarHeight = body.offsetHeight / self.refs.scrollContents.offsetHeight * 100;

            self.barHeight = scrollBarHeight < 100 ? scrollBarHeight : 100;
            if(!isUndefined(self.refs.scrollBar)) {
                self.refs.scrollBar.style.height = self.barHeight + "%";
                self.refs.scrollBarArea.style.display = self.barHeight < 100 ? "block" : "none";
            }
        }

        // スクロールバーの位置を変更する
        function setScrollBarPosition(body){
            // メインページ→編成→メインページとかでいったり来たりする場合にとれないことがあるのでチェック
            if (isUndefined(body)) return;
            if (isUndefined(self.refs.scrollBody) || isUndefined(self.refs.scrollContents)) return;
            if (self.barHeight < 100) {

                var scrollTop = Math.ceil(body.scrollTop);
                var scrollBottom = Math.ceil(body.scrollHeight - body.offsetHeight);
                var scrollHeight = Math.ceil(body.scrollHeight);
                var scrollBarArea = self.refs.scrollBarArea;

                var scrollBarPosition = 0;
                var maxBarPosition = 100;
                // 0除算を防ぐ
                if (scrollHeight !== 0) {
                    scrollBarPosition = (scrollTop / scrollHeight * 100);
                    maxBarPosition = ((body.scrollHeight - body.offsetHeight) / scrollHeight) * 100;
                }

                var position = scrollBarPosition > 0 ? maxBarPosition <= scrollBarPosition ? maxBarPosition : scrollBarPosition : 0;
                self.refs.scrollBar.style.transform = "translateY(" + (scrollBarArea.offsetHeight * (position / 100)) + "px)";

                if (scrollTop === scrollBottom && self.positionState !== "bottom") {
                    self.positionState = "bottom";
                } else if (scrollTop > 0 && scrollTop < scrollBottom && self.positionState !== "middle") {
                    self.positionState = "middle";
                } else if (scrollTop === 0 && self.positionState !== "top") {
                    self.positionState = "top";
                }
            } else {
                self.positionState = "no-scroll";
            }
            self.refs.scrollParts.setAttribute("class", "scroll-parts " + self.positionState);
        }

        // サイズや位置などを再計算し直す
        function updateScrollParts (){
            var body = self.refs.scrollBody;
            if(body instanceof Array) return;
            setScrollBarSize(body);
            setScrollBarPosition(body);
        }

        function isUndefined(item) {
            return typeof item === "undefined" || item === null;
        }

    </script>
</scroll>