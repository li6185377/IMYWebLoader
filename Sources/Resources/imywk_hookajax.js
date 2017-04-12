(function() {
    if (window.imy_realxhr) {
        return
    }
    window.imy_realxhr = XMLHttpRequest;
    var timestamp = new Date().getTime();
    timestamp = parseInt((timestamp / 1000) % 100000);
    var global_index = timestamp + 1;
    var global_map = {};
    window.imy_realxhr_callback = function(id, message) {
        var hookAjax = global_map[id];
        if (hookAjax) {
            hookAjax.callbackNative(message)
        }
        global_map[id] = null
    };

    function BaseHookAjax() {}
    BaseHookAjax.prototype = window.imy_realxhr;

    function hookAjax() {}
    hookAjax.prototype = BaseHookAjax;
    hookAjax.prototype.readyState = 0;
    hookAjax.prototype.responseText = "";
    hookAjax.prototype.responseHeaders = {};
    hookAjax.prototype.status = 0;
    hookAjax.prototype.statusText = "";
    hookAjax.prototype.onreadystatechange = null;
    hookAjax.prototype.onload = null;
    hookAjax.prototype.onerror = null;
    hookAjax.prototype.onabort = null;
    hookAjax.prototype.open = function() {
        this.open_arguments = arguments;
        this.readyState = 1;
        if (this.onreadystatechange) {
            this.onreadystatechange()
        }
    };
    hookAjax.prototype.setRequestHeader = function(name, value) {
        if (!this._headers) {
            this._headers = {}
        }
        this._headers[name] = value
    };
    hookAjax.prototype.send = function() {
        if (arguments.length >= 1 && !!arguments[0]) {
            this.sendNative(arguments[0])
        } else {
            var xhr = new window.imy_realxhr();
            this._xhr = xhr;
            var that = this;
            xhr.onreadystatechange = function() {
                that.readyState = xhr.readyState;
                if (that.readyState <= 1) {
                    return
                }
                if (xhr.readyState >= 3) {
                    that.status = xhr.status;
                    that.statusText = xhr.statusText;
                    that.responseText = xhr.responseText;
                }
                that.callbackStateChanged();
            };
            xhr.open.apply(xhr, this.open_arguments);
            for (name in this._headers) {
                xhr.setRequestHeader(name, this._headers[name])
            }
            xhr.send.apply(xhr, arguments)
        }
    };
    hookAjax.prototype.sendNative = function(data) {
        this.request_id = global_index;
        global_map[this.request_id] = this;
        global_index++;
        var message = {};
        message.id = this.request_id;
        message.data = data;
        message.method = this.open_arguments[0];
        message.url = this.open_arguments[1];
        message.headers = this._headers;
        window.webkit.messageHandlers.IMYXHR.postMessage(message)
    };
    hookAjax.prototype.callbackNative = function(message) {
        if (!this.is_abort) {
            this.status = message.status;
            this.responseText = (!!message.data) ? message.data : "";
            this.responseHeaders = message.headers;
            this.readyState = 4
        } else {
            this.readyState = 1
        }
        this.callbackStateChanged();
    };
    hookAjax.prototype.callbackStateChanged = function() {
        if (this.readyState >= 3) {
            if (this.status >= 200 && this.status < 300) {
                this.statusText = "OK"
            } else {
                this.statusText = "Fail"
            }
        }
        if (this.onreadystatechange) {
            this.onreadystatechange()
        }
        if (this.readyState == 4) {
            if (this.statusText == "OK") {
                this.onload ? this.onload() : ""
            } else {
                this.onerror ? this.onerror() : ""
            }
        }
    };
    hookAjax.prototype.abort = function() {
        this.is_abort = true;
        if (this._xhr) {
            this._xhr.abort()
        }
        if (this.onabort) {
            this.onabort()
        }
    };
    hookAjax.prototype.getAllResponseHeaders = function() {
        if (this._xhr) {
            return this._xhr.getAllResponseHeaders()
        } else {
            return this.responseHeaders
        }
    };
    hookAjax.prototype.getResponseHeader = function(name) {
        if (this._xhr) {
            return this._xhr.getResponseHeader(name)
        } else {
            for (key in this.responseHeaders) {
                if (key.toLowerCase() == name.toLowerCase()) {
                    return this.responseHeaders[key]
                }
            }
            return null
        }
    };
    XMLHttpRequest = hookAjax;
    window.imy_hookAjax = function() {
        XMLHttpRequest = hookAjax
    };
    window.imy_unhookAjax = function() {
        XMLHttpRequest = window.imy_realxhr
    }
})();
