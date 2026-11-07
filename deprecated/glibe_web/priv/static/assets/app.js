(() => {
  var __defProp = Object.defineProperty;
  var __defProps = Object.defineProperties;
  var __getOwnPropDescs = Object.getOwnPropertyDescriptors;
  var __getOwnPropSymbols = Object.getOwnPropertySymbols;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __propIsEnum = Object.prototype.propertyIsEnumerable;
  var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
  var __spreadValues = (a2, b2) => {
    for (var prop in b2 || (b2 = {}))
      if (__hasOwnProp.call(b2, prop))
        __defNormalProp(a2, prop, b2[prop]);
    if (__getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(b2)) {
        if (__propIsEnum.call(b2, prop))
          __defNormalProp(a2, prop, b2[prop]);
      }
    return a2;
  };
  var __spreadProps = (a2, b2) => __defProps(a2, __getOwnPropDescs(b2));
  var __objRest = (source, exclude) => {
    var target = {};
    for (var prop in source)
      if (__hasOwnProp.call(source, prop) && exclude.indexOf(prop) < 0)
        target[prop] = source[prop];
    if (source != null && __getOwnPropSymbols)
      for (var prop of __getOwnPropSymbols(source)) {
        if (exclude.indexOf(prop) < 0 && __propIsEnum.call(source, prop))
          target[prop] = source[prop];
      }
    return target;
  };

  // node_modules/phoenix_live_view/priv/static/phoenix_live_view.esm.js
  var CONSECUTIVE_RELOADS = "consecutive-reloads";
  var MAX_RELOADS = 10;
  var RELOAD_JITTER_MIN = 5e3;
  var RELOAD_JITTER_MAX = 1e4;
  var FAILSAFE_JITTER = 3e4;
  var PHX_EVENT_CLASSES = [
    "phx-click-loading",
    "phx-change-loading",
    "phx-submit-loading",
    "phx-keydown-loading",
    "phx-keyup-loading",
    "phx-blur-loading",
    "phx-focus-loading",
    "phx-hook-loading"
  ];
  var PHX_DROP_TARGET_ACTIVE_CLASS = "phx-drop-target-active";
  var PHX_COMPONENT = "data-phx-component";
  var PHX_VIEW_REF = "data-phx-view";
  var PHX_LIVE_LINK = "data-phx-link";
  var PHX_TRACK_STATIC = "track-static";
  var PHX_LINK_STATE = "data-phx-link-state";
  var PHX_REF_LOADING = "data-phx-ref-loading";
  var PHX_REF_SRC = "data-phx-ref-src";
  var PHX_REF_LOCK = "data-phx-ref-lock";
  var PHX_PENDING_REFS = "phx-pending-refs";
  var PHX_TRACK_UPLOADS = "track-uploads";
  var PHX_UPLOAD_REF = "data-phx-upload-ref";
  var PHX_PREFLIGHTED_REFS = "data-phx-preflighted-refs";
  var PHX_DONE_REFS = "data-phx-done-refs";
  var PHX_ERROR_REFS = "data-phx-error-refs";
  var PHX_DROP_TARGET = "drop-target";
  var PHX_ACTIVE_ENTRY_REFS = "data-phx-active-refs";
  var PHX_LIVE_FILE_UPDATED = "phx:live-file:updated";
  var PHX_SKIP = "data-phx-skip";
  var PHX_MAGIC_ID = "data-phx-id";
  var PHX_PRUNE = "data-phx-prune";
  var PHX_CONNECTED_CLASS = "phx-connected";
  var PHX_LOADING_CLASS = "phx-loading";
  var PHX_ERROR_CLASS = "phx-error";
  var PHX_CLIENT_ERROR_CLASS = "phx-client-error";
  var PHX_SERVER_ERROR_CLASS = "phx-server-error";
  var PHX_PARENT_ID = "data-phx-parent-id";
  var PHX_MAIN = "data-phx-main";
  var PHX_ROOT_ID = "data-phx-root-id";
  var PHX_VIEWPORT_TOP = "viewport-top";
  var PHX_VIEWPORT_BOTTOM = "viewport-bottom";
  var PHX_VIEWPORT_OVERRUN_TARGET = "viewport-overrun-target";
  var PHX_TRIGGER_ACTION = "trigger-action";
  var PHX_HAS_FOCUSED = "phx-has-focused";
  var FOCUSABLE_INPUTS = [
    "text",
    "textarea",
    "number",
    "email",
    "password",
    "search",
    "tel",
    "url",
    "date",
    "time",
    "datetime-local",
    "color",
    "range"
  ];
  var CHECKABLE_INPUTS = ["checkbox", "radio"];
  var PHX_HAS_SUBMITTED = "phx-has-submitted";
  var PHX_SESSION = "data-phx-session";
  var PHX_VIEW_SELECTOR = `[${PHX_SESSION}]`;
  var PHX_STICKY = "data-phx-sticky";
  var PHX_STATIC = "data-phx-static";
  var PHX_READONLY = "data-phx-readonly";
  var PHX_DISABLED = "data-phx-disabled";
  var PHX_DISABLE_WITH = "disable-with";
  var PHX_DISABLE_WITH_RESTORE = "data-phx-disable-with-restore";
  var PHX_HOOK = "hook";
  var PHX_DEBOUNCE = "debounce";
  var PHX_THROTTLE = "throttle";
  var PHX_UPDATE = "update";
  var PHX_PATCH_FOCUSED = "patch-focused";
  var PHX_STREAM = "stream";
  var PHX_STREAM_REF = "data-phx-stream";
  var PHX_PORTAL = "data-phx-portal";
  var PHX_TELEPORTED_REF = "data-phx-teleported";
  var PHX_TELEPORTED_SRC = "data-phx-teleported-src";
  var PHX_RUNTIME_HOOK = "data-phx-runtime-hook";
  var PHX_LV_PID = "data-phx-pid";
  var PHX_KEY = "key";
  var PHX_PRIVATE = "phxPrivate";
  var PHX_AUTO_RECOVER = "auto-recover";
  var PHX_NO_UNUSED_FIELD = "no-unused-field";
  var PHX_LV_DEBUG = "phx:live-socket:debug";
  var PHX_LV_PROFILE = "phx:live-socket:profiling";
  var PHX_LV_LATENCY_SIM = "phx:live-socket:latency-sim";
  var PHX_LV_HISTORY_POSITION = "phx:nav-history-position";
  var PHX_PROGRESS = "progress";
  var PHX_MOUNTED = "mounted";
  var PHX_RELOAD_STATUS = "__phoenix_reload_status__";
  var LOADER_TIMEOUT = 1;
  var MAX_CHILD_JOIN_ATTEMPTS = 3;
  var BEFORE_UNLOAD_LOADER_TIMEOUT = 200;
  var DISCONNECTED_TIMEOUT = 500;
  var BINDING_PREFIX = "phx-";
  var PUSH_TIMEOUT = 3e4;
  var DEBOUNCE_TRIGGER = "debounce-trigger";
  var THROTTLED = "throttled";
  var DEBOUNCE_PREV_KEY = "debounce-prev-key";
  var DEFAULTS = {
    debounce: 300,
    throttle: 300
  };
  var PHX_PENDING_ATTRS = [PHX_REF_LOADING, PHX_REF_SRC, PHX_REF_LOCK];
  var STATIC = "s";
  var ROOT = "r";
  var COMPONENTS = "c";
  var KEYED = "k";
  var KEYED_COUNT = "kc";
  var KEYED_MOVED = "km";
  var EVENTS = "e";
  var REPLY = "r";
  var TITLE = "t";
  var TEMPLATES = "p";
  var STREAM = "stream";
  var PHX_LV_DIAGNOSTIC_EVENT = "phx:live-view:diagnostic";
  var PHX_LV_DIAGNOSTIC_VERSION = 1;
  var EntryUploader = class {
    constructor(entry, config, liveSocket2) {
      const { chunk_size, chunk_timeout } = config;
      this.liveSocket = liveSocket2;
      this.entry = entry;
      this.offset = 0;
      this.chunkSize = chunk_size;
      this.chunkTimeout = chunk_timeout;
      this.chunkTimer = null;
      this.errored = false;
      this.uploadChannel = liveSocket2.channel(`lvu:${entry.ref}`, {
        token: entry.metadata()
      });
    }
    error(reason) {
      if (this.errored) {
        return;
      }
      this.entry.view.cancelSubmit(this.entry.fileEl.form);
      this.uploadChannel.leave();
      this.errored = true;
      this.chunkTimer != null && clearTimeout(this.chunkTimer);
      if (reason === "writer_error") {
        return;
      }
      this.entry.error(reason);
    }
    upload() {
      this.uploadChannel.onError((reason) => this.error(reason));
      this.uploadChannel.join().receive("ok", (_data) => this.readNextChunk()).receive("error", ({ reason }) => this.error(reason));
    }
    isDone() {
      return this.offset >= this.entry.file.size;
    }
    readNextChunk() {
      const reader = new window.FileReader();
      const blob = this.entry.file.slice(
        this.offset,
        this.chunkSize + this.offset
      );
      reader.onload = (e2) => {
        var _a, _b;
        if (((_a = e2.target) == null ? void 0 : _a.error) === null) {
          this.offset += /** @type {ArrayBuffer} */
          e2.target.result.byteLength;
          this.pushChunk(
            /** @type {ArrayBuffer} */
            e2.target.result
          );
        } else {
          return this.entry.view.logError(
            "upload.read-failed",
            "Read error: " + ((_b = e2.target) == null ? void 0 : _b.error),
            { entry: this.entry, offset: this.offset }
          );
        }
      };
      reader.readAsArrayBuffer(blob);
    }
    pushChunk(chunk) {
      if (!this.uploadChannel.isJoined()) {
        return;
      }
      this.uploadChannel.push("chunk", chunk, this.chunkTimeout).receive("ok", () => {
        this.entry.progress(this.offset / this.entry.file.size * 100);
        if (!this.isDone()) {
          this.chunkTimer = setTimeout(
            () => this.readNextChunk(),
            this.liveSocket.getLatencySim() || 0
          );
        }
      }).receive("error", ({ reason }) => this.error(reason));
    }
  };
  var dispatchDiagnostic = (diagnostic) => {
    window.dispatchEvent(
      new CustomEvent(PHX_LV_DIAGNOSTIC_EVENT, {
        detail: __spreadValues({
          version: PHX_LV_DIAGNOSTIC_VERSION
        }, diagnostic)
      })
    );
  };
  var logError = (code, message, metadata, context) => {
    console.error && console.error(message, metadata);
    dispatchDiagnostic(__spreadValues({
      level: "error",
      code,
      message,
      metadata
    }, context));
  };
  var ensureSameOrigin = (href, kind) => {
    let url;
    try {
      url = new URL(href, window.location.href);
    } catch (e2) {
      throw new Error(
        `expected ${kind} destination to be a valid URL, got: ${href}`
      );
    }
    if (url.origin !== window.location.origin) {
      throw new Error(
        `cannot ${kind} to "${href}" because its origin does not match the current origin "${window.location.origin}". Use window.location directly for cross-origin navigation.`
      );
    }
  };
  var isCid = (cid) => {
    const type = typeof cid;
    return type === "number" || type === "string" && /^(0|[1-9]\d*)$/.test(cid);
  };
  function detectDuplicateIds(reportError = logError) {
    const ids = /* @__PURE__ */ new Map();
    const elems = document.querySelectorAll("*[id]");
    for (let i = 0, len = elems.length; i < len; i++) {
      const id = elems[i].id;
      const existing = ids.get(id);
      if (existing) {
        reportError(
          "dom.duplicate-id",
          `Multiple IDs detected: ${id}. Ensure unique element ids.`,
          { id, elements: [existing, elems[i]] },
          { attribution: "app" }
        );
      } else {
        ids.set(id, elems[i]);
      }
    }
  }
  function detectInvalidStreamInserts(inserts, reportError = logError) {
    const invalidContainers = /* @__PURE__ */ new Set();
    Object.keys(inserts).forEach((id) => {
      const streamEl = document.getElementById(id);
      if (streamEl && streamEl.parentElement && streamEl.parentElement.getAttribute("phx-update") !== "stream") {
        invalidContainers.add(streamEl.parentElement);
      }
    });
    invalidContainers.forEach((container) => {
      const id = container.id;
      reportError(
        "dom.invalid-stream-container",
        `The stream container with id "${id}" is missing the phx-update="stream" attribute. Ensure it is set for streams to work properly.`,
        { id, container },
        { attribution: "app" }
      );
    });
  }
  var debug = (view, kind, msg, obj) => {
    if (view.liveSocket.isDebugEnabled()) {
      console.log(`${view.id} ${kind}: ${msg} - `, obj);
    }
  };
  var closure = (val) => typeof val === "function" ? val : function() {
    return val;
  };
  var clone = (obj) => {
    return JSON.parse(JSON.stringify(obj));
  };
  var deepClone = (obj) => {
    if ("structuredClone" in window) {
      return structuredClone(obj);
    } else {
      return JSON.parse(JSON.stringify(obj));
    }
  };
  var closestPhxBinding = (startEl, binding, borderEl) => {
    let el = startEl;
    do {
      if (el.matches(`[${binding}]`) && !("disabled" in el && el.disabled)) {
        return el;
      }
      el = el.parentElement;
    } while (el !== null && el.nodeType === 1 && !(borderEl && borderEl.isSameNode(el) || el.matches(PHX_VIEW_SELECTOR)));
    return null;
  };
  var isObject = (obj) => {
    return obj !== null && typeof obj === "object" && !(obj instanceof Array);
  };
  var isEqualObj = (obj1, obj2) => JSON.stringify(obj1) === JSON.stringify(obj2);
  var isEmpty = (obj) => {
    for (const x2 in obj) {
      return false;
    }
    return true;
  };
  var maybe = (el, callback) => el && callback(el);
  var channelUploader = function(entries, onError, resp, liveSocket2) {
    entries.forEach((entry) => {
      const entryUploader = new EntryUploader(entry, resp.config, liveSocket2);
      entryUploader.upload();
    });
  };
  var eventContainsFiles = (e2) => {
    if (e2.dataTransfer.types) {
      for (let i = 0; i < e2.dataTransfer.types.length; i++) {
        if (e2.dataTransfer.types[i] === "Files") {
          return true;
        }
      }
    }
    return false;
  };
  var Browser = {
    canPushState() {
      return typeof history.pushState !== "undefined";
    },
    dropLocal(localStorage, namespace, subkey) {
      return localStorage.removeItem(this.localKey(namespace, subkey));
    },
    updateLocal(localStorage, namespace, subkey, initial, func) {
      const current = this.getLocal(localStorage, namespace, subkey);
      const key = this.localKey(namespace, subkey);
      const newVal = current === null ? initial : func(current);
      localStorage.setItem(key, JSON.stringify(newVal));
      return newVal;
    },
    getLocal(localStorage, namespace, subkey) {
      return JSON.parse(localStorage.getItem(this.localKey(namespace, subkey)));
    },
    updateCurrentState(callback) {
      if (!this.canPushState()) {
        return;
      }
      history.replaceState(
        callback(history.state || {}),
        "",
        window.location.href
      );
    },
    pushState(kind, meta, to) {
      if (this.canPushState()) {
        if (to !== window.location.href) {
          if (meta.type == "redirect" && meta.scroll) {
            const currentState = history.state || {};
            currentState.scroll = meta.scroll;
            history.replaceState(currentState, "", window.location.href);
          }
          delete meta.scroll;
          history[kind + "State"](meta, "", to || null);
          window.requestAnimationFrame(() => {
            const hashEl = this.getHashTargetEl(window.location.hash);
            if (hashEl) {
              hashEl.scrollIntoView();
            } else if (meta.type === "redirect") {
              window.scroll(0, 0);
            }
          });
        }
      } else if (to) {
        this.redirect(to);
      }
    },
    setCookie(name, value, maxAgeSeconds) {
      const expires = typeof maxAgeSeconds === "number" ? ` max-age=${maxAgeSeconds};` : "";
      document.cookie = `${name}=${value};${expires} path=/`;
    },
    getCookie(name) {
      return document.cookie.replace(
        new RegExp(`(?:(?:^|.*;s*)${name}s*=s*([^;]*).*$)|^.*$`),
        "$1"
      );
    },
    deleteCookie(name) {
      document.cookie = `${name}=; max-age=-1; path=/`;
    },
    redirect(toURL, flash = null, navigate = (url) => {
      window.location.href = url;
    }) {
      if (flash) {
        this.setCookie("__phoenix_flash__", flash, 60);
      }
      navigate(toURL);
    },
    localKey(namespace, subkey) {
      return `${namespace}-${subkey}`;
    },
    getHashTargetEl(maybeHash) {
      const hash = maybeHash.toString().substring(1);
      if (hash === "") {
        return;
      }
      return document.getElementById(hash) || document.querySelector(`a[name="${hash}"]`);
    }
  };
  var browser_default = Browser;
  var DOM = {
    byId(id) {
      return document.getElementById(id) || logError(
        "dom.element-not-found",
        `no id found for ${id}`,
        { id },
        { attribution: "internal" }
      );
    },
    elementFromTarget(target) {
      if (!(target instanceof Node)) {
        return null;
      }
      if (target.nodeType === Node.ELEMENT_NODE) {
        return target;
      } else {
        return target.parentElement;
      }
    },
    removeClass(el, className) {
      el.classList.remove(className);
      if (el.classList.length === 0) {
        el.removeAttribute("class");
      }
    },
    all(node, query, callback) {
      if (!node) {
        return [];
      }
      const array = Array.from(node.querySelectorAll(query));
      if (callback) {
        array.forEach(callback);
      }
      return array;
    },
    isUploadInput(el) {
      return el.type === "file" && el.getAttribute(PHX_UPLOAD_REF) !== null;
    },
    isAutoUpload(inputEl) {
      return inputEl.hasAttribute("data-phx-auto-upload");
    },
    findUploadInputs(node) {
      const formId = node.id;
      const inputsOutsideForm = this.all(
        document,
        `input[type="file"][${PHX_UPLOAD_REF}][form="${formId}"]`
      );
      return this.all(node, `input[type="file"][${PHX_UPLOAD_REF}]`).concat(
        inputsOutsideForm
      );
    },
    findComponent(viewId, cid, doc2 = document) {
      return doc2.querySelector(
        `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
      );
    },
    getComponent(viewId, cid, doc2 = document) {
      const el = this.findComponent(viewId, cid, doc2);
      if (!el) {
        throw new Error(
          `no component found matching viewId ${viewId} and cid ${cid}`
        );
      }
      return el;
    },
    isPhxDestroyed(node) {
      return node.id && DOM.private(node, "destroyed") ? true : false;
    },
    wantsNewTab(e2) {
      const wantsNewTab = e2.ctrlKey || e2.shiftKey || e2.metaKey || e2.button && e2.button === 1;
      const isDownload = e2.target instanceof HTMLAnchorElement && e2.target.hasAttribute("download");
      const isTargetBlank = e2.target.hasAttribute("target") && e2.target.getAttribute("target").toLowerCase() === "_blank";
      const isTargetNamedTab = e2.target.hasAttribute("target") && !e2.target.getAttribute("target").startsWith("_");
      return wantsNewTab || isTargetBlank || isDownload || isTargetNamedTab;
    },
    isUnloadableFormSubmit(e2) {
      const isDialogSubmit = e2.target && e2.target.getAttribute("method") === "dialog" || e2.submitter && e2.submitter.getAttribute("formmethod") === "dialog";
      if (isDialogSubmit) {
        return false;
      } else {
        return !e2.defaultPrevented && !this.wantsNewTab(e2);
      }
    },
    isNewPageClick(e2, currentLocation) {
      const href = e2.target instanceof HTMLAnchorElement ? e2.target.getAttribute("href") : null;
      let url;
      if (e2.defaultPrevented || href === null || this.wantsNewTab(e2)) {
        return false;
      }
      if (href.startsWith("mailto:") || href.startsWith("tel:")) {
        return false;
      }
      if (e2.target.isContentEditable) {
        return false;
      }
      try {
        url = new URL(href);
      } catch (e3) {
        try {
          url = new URL(href, currentLocation);
        } catch (e4) {
          return true;
        }
      }
      if (url.host === currentLocation.host && url.protocol === currentLocation.protocol) {
        if (url.pathname === currentLocation.pathname && url.search === currentLocation.search) {
          return url.hash === "" && !url.href.endsWith("#");
        }
      }
      return url.protocol.startsWith("http");
    },
    markPhxChildDestroyed(el) {
      if (this.isPhxChild(el)) {
        el.setAttribute(PHX_SESSION, "");
      }
      this.putPrivate(el, "destroyed", true);
    },
    findPhxChildrenInFragment(html, parentId) {
      const template = document.createElement("template");
      template.innerHTML = html;
      return this.findPhxChildren(template.content, parentId);
    },
    isIgnored(el, phxUpdate) {
      return (el.getAttribute(phxUpdate) || el.getAttribute("data-phx-update")) === "ignore";
    },
    isPhxUpdate(el, phxUpdate, updateTypes) {
      return el.getAttribute && updateTypes.indexOf(el.getAttribute(phxUpdate)) >= 0;
    },
    findPhxSticky(el) {
      return this.all(el, `[${PHX_STICKY}]`);
    },
    findPhxChildren(el, parentId) {
      return this.all(el, `${PHX_VIEW_SELECTOR}[${PHX_PARENT_ID}="${parentId}"]`);
    },
    findExistingParentCIDs(viewId, cids) {
      const parentCids = /* @__PURE__ */ new Set();
      const childrenCids = /* @__PURE__ */ new Set();
      cids.forEach((cid) => {
        this.all(
          document,
          `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
        ).forEach((parent) => {
          parentCids.add(cid);
          this.all(parent, `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}]`).map((el) => parseInt(el.getAttribute(PHX_COMPONENT))).forEach((childCID) => childrenCids.add(childCID));
        });
      });
      childrenCids.forEach((childCid) => parentCids.delete(childCid));
      return parentCids;
    },
    private(el, key) {
      return el[PHX_PRIVATE] && el[PHX_PRIVATE][key];
    },
    deletePrivate(el, key) {
      el[PHX_PRIVATE] && delete el[PHX_PRIVATE][key];
    },
    putPrivate(el, key, value) {
      if (!el[PHX_PRIVATE]) {
        el[PHX_PRIVATE] = {};
      }
      el[PHX_PRIVATE][key] = value;
    },
    updatePrivate(el, key, defaultVal, updateFunc) {
      const existing = this.private(el, key);
      if (existing === void 0) {
        this.putPrivate(el, key, updateFunc(defaultVal));
      } else {
        this.putPrivate(el, key, updateFunc(existing));
      }
    },
    syncPendingAttrs(fromEl, toEl) {
      if (!fromEl.hasAttribute(PHX_REF_SRC)) {
        return;
      }
      PHX_EVENT_CLASSES.forEach((className) => {
        fromEl.classList.contains(className) && toEl.classList.add(className);
      });
      PHX_PENDING_ATTRS.filter((attr) => fromEl.hasAttribute(attr)).forEach(
        (attr) => {
          toEl.setAttribute(attr, fromEl.getAttribute(attr));
        }
      );
    },
    copyPrivates(target, source) {
      if (source[PHX_PRIVATE]) {
        target[PHX_PRIVATE] = source[PHX_PRIVATE];
      }
    },
    putTitle(str) {
      const titleEl = document.querySelector("title");
      if (titleEl) {
        const { prefix, suffix, default: defaultTitle } = titleEl.dataset;
        const isEmpty2 = typeof str !== "string" || str.trim() === "";
        if (isEmpty2 && typeof defaultTitle !== "string") {
          return;
        }
        const inner = isEmpty2 ? defaultTitle : str;
        document.title = `${prefix || ""}${inner || ""}${suffix || ""}`;
      } else {
        document.title = str;
      }
    },
    debounce(el, event, phxDebounce, defaultDebounce, phxThrottle, defaultThrottle, asyncFilter, callback) {
      let debounce = el.getAttribute(phxDebounce);
      let throttle = el.getAttribute(phxThrottle);
      if (debounce === "") {
        debounce = defaultDebounce;
      }
      if (throttle === "") {
        throttle = defaultThrottle;
      }
      const value = debounce || throttle;
      switch (value) {
        case null:
          return callback();
        case "blur":
          this.incCycle(el, "debounce-blur-cycle", () => {
            if (asyncFilter()) {
              callback();
            }
          });
          if (this.once(el, "debounce-blur")) {
            el.addEventListener(
              "blur",
              () => this.triggerCycle(el, "debounce-blur-cycle")
            );
          }
          return;
        default:
          const timeout = parseInt(value);
          const trigger = () => throttle ? this.deletePrivate(el, THROTTLED) : callback();
          const currentCycle = this.incCycle(el, DEBOUNCE_TRIGGER, trigger);
          if (isNaN(timeout)) {
            return logError(
              "dom.invalid-debounce",
              `invalid throttle/debounce value: ${value}`,
              { el, value },
              { attribution: "app" }
            );
          }
          if (throttle) {
            let newKeyDown = false;
            if (event.type === "keydown") {
              const prevKey = this.private(el, DEBOUNCE_PREV_KEY);
              this.putPrivate(el, DEBOUNCE_PREV_KEY, event.key);
              newKeyDown = prevKey !== event.key;
            }
            if (!newKeyDown && this.private(el, THROTTLED)) {
              return false;
            } else {
              callback();
              const t = setTimeout(() => {
                if (asyncFilter()) {
                  this.triggerCycle(el, DEBOUNCE_TRIGGER);
                }
              }, timeout);
              this.putPrivate(el, THROTTLED, t);
            }
          } else {
            setTimeout(() => {
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER, currentCycle);
              }
            }, timeout);
          }
          const form = el.form;
          if (form && this.once(form, "bind-debounce")) {
            form.addEventListener("submit", () => {
              Array.from(new FormData(form).entries(), ([name]) => {
                const namedItem = form.elements.namedItem(name);
                const input = namedItem instanceof RadioNodeList ? namedItem[0] : namedItem;
                if (input) {
                  this.incCycle(input, DEBOUNCE_TRIGGER);
                  this.deletePrivate(input, THROTTLED);
                }
              });
            });
          }
          if (this.once(el, "bind-debounce")) {
            el.addEventListener("blur", () => {
              clearTimeout(this.private(el, THROTTLED));
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER);
              }
            });
          }
      }
    },
    triggerCycle(el, key, currentCycle) {
      const [cycle, trigger] = this.private(el, key);
      if (!currentCycle) {
        currentCycle = cycle;
      }
      if (currentCycle === cycle) {
        this.incCycle(el, key);
        trigger();
      }
    },
    once(el, key) {
      if (this.private(el, key) === true) {
        return false;
      }
      this.putPrivate(el, key, true);
      return true;
    },
    incCycle(el, key, trigger = function() {
    }) {
      let [currentCycle] = this.private(el, key) || [0, trigger];
      currentCycle++;
      this.putPrivate(el, key, [currentCycle, trigger]);
      return currentCycle;
    },
    // maintains or adds privately used hook information
    // fromEl and toEl can be the same element in the case of a newly added node
    // fromEl and toEl can be any HTML node type, so we need to check if it's an element node
    maintainPrivateHooks(fromEl, toEl, phxViewportTop, phxViewportBottom) {
      if (fromEl.hasAttribute && fromEl.hasAttribute("data-phx-hook") && !toEl.hasAttribute("data-phx-hook")) {
        toEl.setAttribute("data-phx-hook", fromEl.getAttribute("data-phx-hook"));
      }
      if (toEl.hasAttribute && (toEl.hasAttribute(phxViewportTop) || toEl.hasAttribute(phxViewportBottom))) {
        toEl.setAttribute("data-phx-hook", "Phoenix.InfiniteScroll");
      }
    },
    putCustomElHook(el, hook) {
      if (el.isConnected) {
        el.setAttribute("data-phx-hook", "");
      } else {
        logError(
          "hook.non-connected-element",
          `
        hook attached to non-connected DOM element
        ensure you are calling createHook within your connectedCallback. ${el.outerHTML}
      `,
          { el },
          { attribution: "app" }
        );
      }
      this.putPrivate(el, "custom-el-hook", hook);
    },
    getCustomElHook(el) {
      return this.private(el, "custom-el-hook");
    },
    isUsedInput(el) {
      return el.nodeType === Node.ELEMENT_NODE && (this.private(el, PHX_HAS_FOCUSED) || this.private(el, PHX_HAS_SUBMITTED));
    },
    resetForm(form) {
      Array.from(form.elements).forEach((input) => {
        this.deletePrivate(input, PHX_HAS_FOCUSED);
        this.deletePrivate(input, PHX_HAS_SUBMITTED);
      });
    },
    isPhxChild(node) {
      return node.getAttribute && node.getAttribute(PHX_PARENT_ID);
    },
    isPhxSticky(node) {
      return node.getAttribute && node.getAttribute(PHX_STICKY) !== null;
    },
    isChildOfAny(el, parents) {
      return !!parents.find((parent) => parent.contains(el));
    },
    firstPhxChild(el) {
      return this.isPhxChild(el) ? el : this.all(el, `[${PHX_PARENT_ID}]`)[0];
    },
    isPortalTemplate(el) {
      return el.tagName === "TEMPLATE" && el.hasAttribute(PHX_PORTAL);
    },
    closestViewEl(el) {
      const portalOrViewEl = el.closest(
        `[${PHX_TELEPORTED_REF}],${PHX_VIEW_SELECTOR}`
      );
      if (!portalOrViewEl) {
        return null;
      }
      if (portalOrViewEl.hasAttribute(PHX_TELEPORTED_REF)) {
        return this.byId(portalOrViewEl.getAttribute(PHX_TELEPORTED_REF));
      } else if (portalOrViewEl.hasAttribute(PHX_SESSION)) {
        return portalOrViewEl;
      }
      return null;
    },
    dispatchEvent(target, name, opts = {}) {
      let defaultBubble = true;
      const isUploadTarget = target.nodeName === "INPUT" && target.type === "file";
      if (isUploadTarget && name === "click") {
        defaultBubble = false;
      }
      const bubbles = opts.bubbles === void 0 ? defaultBubble : !!opts.bubbles;
      const eventOpts = {
        bubbles,
        cancelable: true,
        detail: opts.detail || {}
      };
      const event = name === "click" ? new MouseEvent("click", eventOpts) : new CustomEvent(name, eventOpts);
      return target.dispatchEvent(event);
    },
    cloneNode(node, html) {
      if (typeof html === "undefined") {
        return node.cloneNode(true);
      } else {
        const cloned = node.cloneNode(false);
        cloned.innerHTML = html;
        return cloned;
      }
    },
    // merge attributes from source to target
    // if an element is ignored, we only merge data attributes
    // including removing data attributes that are no longer in the source
    mergeAttrs(target, source, opts = {}) {
      var _a;
      const exclude = new Set(opts.exclude || []);
      const isIgnored = opts.isIgnored;
      const sourceAttrs = source.attributes;
      for (let i = sourceAttrs.length - 1; i >= 0; i--) {
        const name = sourceAttrs[i].name;
        if (!exclude.has(name)) {
          const sourceValue = source.getAttribute(name);
          if (target.getAttribute(name) !== sourceValue && (!isIgnored || isIgnored && name.startsWith("data-"))) {
            target.setAttribute(name, sourceValue);
          }
        } else {
          if (name === "value") {
            const sourceValue = (_a = source.value) != null ? _a : source.getAttribute(name);
            if (target.value === sourceValue) {
              target.setAttribute("value", source.getAttribute(name));
            }
          }
        }
      }
      const targetAttrs = target.attributes;
      for (let i = targetAttrs.length - 1; i >= 0; i--) {
        const name = targetAttrs[i].name;
        if (isIgnored) {
          if (name.startsWith("data-") && !source.hasAttribute(name) && !PHX_PENDING_ATTRS.includes(name)) {
            target.removeAttribute(name);
          }
        } else {
          if (!source.hasAttribute(name)) {
            target.removeAttribute(name);
          }
        }
      }
    },
    mergeFocusedInput(target, source) {
      if (!(target instanceof HTMLSelectElement)) {
        DOM.mergeAttrs(target, source, { exclude: ["value"] });
      }
      if (source.readOnly) {
        target.setAttribute("readonly", true);
      } else {
        target.removeAttribute("readonly");
      }
    },
    hasSelectionRange(el) {
      return el.setSelectionRange && ["text", "textarea", "search", "url", "tel", "password"].includes(el.type);
    },
    restoreFocus(focused, selectionStart, selectionEnd) {
      if (focused instanceof HTMLSelectElement) {
        focused.focus();
      }
      if (!DOM.isTextualInput(focused)) {
        return;
      }
      const wasFocused = focused.matches(":focus");
      if (!wasFocused) {
        focused.focus();
      }
      if (this.hasSelectionRange(focused)) {
        focused.setSelectionRange(selectionStart, selectionEnd);
      }
    },
    /**
     * Returns true if the element is an input that can be focused and edited by the user,
     * so we can skip patching it if it has focus.
     */
    isEditableInput(el) {
      return this.isFormAssociated(el) && !(el instanceof HTMLButtonElement) && !(el instanceof HTMLInputElement && el.type === "button");
    },
    isFormAssociated(el) {
      if (!(el instanceof HTMLElement))
        return false;
      if (el.localName) {
        const customEl = customElements.get(el.localName);
        if (customEl) {
          return customEl.formAssociated === true;
        }
      }
      return el instanceof HTMLInputElement || el instanceof HTMLSelectElement || el instanceof HTMLTextAreaElement || el instanceof HTMLButtonElement;
    },
    syncAttrsToProps(el) {
      if (el instanceof HTMLInputElement && CHECKABLE_INPUTS.indexOf(el.type.toLocaleLowerCase()) >= 0) {
        el.checked = el.getAttribute("checked") !== null;
      }
    },
    isTextualInput(el) {
      return FOCUSABLE_INPUTS.indexOf(el.type) >= 0;
    },
    isNowTriggerFormExternal(el, phxTriggerExternal) {
      return el.getAttribute && el.getAttribute(phxTriggerExternal) !== null && document.body.contains(el);
    },
    cleanChildNodes(container, phxUpdate, reportError = logError) {
      if (DOM.isPhxUpdate(container, phxUpdate, ["append", "prepend", PHX_STREAM])) {
        const toRemove = [];
        container.childNodes.forEach((childNode) => {
          if (!("id" in childNode) || !childNode.id) {
            const isEmptyTextNode = childNode.nodeType === Node.TEXT_NODE && childNode.nodeValue && childNode.nodeValue.trim() === "";
            if (!isEmptyTextNode && childNode.nodeType !== Node.COMMENT_NODE) {
              reportError(
                "dom.invalid-phx-update-child",
                `only HTML element tags with an id are allowed inside containers with phx-update.

removing illegal node: "${("outerHTML" in childNode && childNode.outerHTML || childNode.nodeValue || "").trim()}"

`,
                { container, childNode, phxUpdate },
                { attribution: "app" }
              );
            }
            toRemove.push(childNode);
          }
        });
        toRemove.forEach((childNode) => childNode.remove());
      }
    },
    replaceRootContainer(container, tagName, attrs) {
      const retainedAttrs = /* @__PURE__ */ new Set([
        "id",
        PHX_SESSION,
        PHX_STATIC,
        PHX_MAIN,
        PHX_ROOT_ID
      ]);
      if (container.tagName.toLowerCase() === tagName.toLowerCase()) {
        Array.from(container.attributes).filter((attr) => !retainedAttrs.has(attr.name.toLowerCase())).forEach((attr) => container.removeAttribute(attr.name));
        Object.keys(attrs).filter((name) => !retainedAttrs.has(name.toLowerCase())).forEach((attr) => container.setAttribute(attr, attrs[attr]));
        return container;
      } else {
        const newContainer = document.createElement(tagName);
        Object.keys(attrs).forEach(
          (attr) => newContainer.setAttribute(attr, attrs[attr])
        );
        retainedAttrs.forEach((attr) => {
          const value = container.getAttribute(attr);
          if (value !== null) {
            newContainer.setAttribute(attr, value);
          }
        });
        newContainer.innerHTML = container.innerHTML;
        container.replaceWith(newContainer);
        return newContainer;
      }
    },
    getSticky(el, name, defaultVal) {
      const op = (DOM.private(el, "sticky") || []).find(
        ([existingName]) => name === existingName
      );
      if (op) {
        const [_name, _op, stashedResult] = op;
        return stashedResult;
      } else {
        return typeof defaultVal === "function" ? defaultVal() : defaultVal;
      }
    },
    putSticky(el, name, op) {
      const stashedResult = op(el);
      this.updatePrivate(el, "sticky", [], (ops) => {
        const existingIndex = ops.findIndex(
          ([existingName]) => name === existingName
        );
        if (existingIndex >= 0) {
          ops[existingIndex] = [name, op, stashedResult];
        } else {
          ops.push([name, op, stashedResult]);
        }
        return ops;
      });
    },
    applyStickyOperations(el) {
      const ops = DOM.private(el, "sticky");
      if (!ops) {
        return;
      }
      ops.forEach(([name, op, _stashed]) => this.putSticky(el, name, op));
    },
    isLocked(el) {
      return el.hasAttribute && el.hasAttribute(PHX_REF_LOCK);
    },
    attributeIgnored(attribute, ignoredAttributes) {
      return ignoredAttributes.some(
        (toIgnore) => attribute.name == toIgnore || toIgnore === "*" || toIgnore.includes("*") && attribute.name.match(toIgnore) != null
      );
    }
  };
  var dom_default = DOM;
  var UploadEntry = class {
    static isActive(fileEl, file) {
      const ref = file._phxRef;
      const isNew = ref === void 0;
      const activeRefs = fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
      const isActive = !isNew && activeRefs.indexOf(ref) >= 0;
      return file.size > 0 && (isNew || isActive);
    }
    static isPreflighted(fileEl, file) {
      const preflightedRefs = fileEl.getAttribute(PHX_PREFLIGHTED_REFS).split(",");
      const isPreflighted = preflightedRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
      return isPreflighted && this.isActive(fileEl, file);
    }
    static isPreflightInProgress(file) {
      return file._preflightInProgress === true;
    }
    static markPreflightInProgress(file) {
      file._preflightInProgress = true;
    }
    constructor(fileEl, file, view, autoUpload) {
      this.ref = LiveUploader.genFileRef(file);
      this.fileEl = fileEl;
      this.file = file;
      this.view = view;
      this.meta = null;
      this._isCancelled = false;
      this._isDone = false;
      this._progress = 0;
      this._lastProgressSent = -1;
      this._onCancel = function() {
      };
      this._onDone = function() {
      };
      this._onElUpdated = this.onElUpdated.bind(this);
      this.fileEl.addEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      this.autoUpload = autoUpload;
    }
    metadata() {
      return this.meta;
    }
    progress(progress) {
      this._progress = Math.floor(progress);
      if (this._progress > this._lastProgressSent) {
        if (this._progress >= 100) {
          this._progress = 100;
          this._lastProgressSent = 100;
          this._isDone = true;
          this.view.pushFileProgress(this.fileEl, this.ref, 100, () => {
            LiveUploader.untrackFile(this.fileEl, this.file);
            this._onDone();
          });
        } else {
          this._lastProgressSent = this._progress;
          this.view.pushFileProgress(this.fileEl, this.ref, this._progress);
        }
      }
    }
    isCancelled() {
      return this._isCancelled;
    }
    cancel() {
      this.file._preflightInProgress = false;
      this._isCancelled = true;
      this._isDone = true;
      try {
        this._onCancel();
      } finally {
        this._onDone();
      }
    }
    isDone() {
      return this._isDone;
    }
    error(reason = "failed") {
      this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      this.view.pushFileProgress(this.fileEl, this.ref, { error: reason });
      if (!this.isAutoUpload()) {
        LiveUploader.clearFiles(this.fileEl);
      }
    }
    isAutoUpload() {
      return this.autoUpload;
    }
    onCancel(callback) {
      if (this.isCancelled()) {
        callback();
      } else {
        this._onCancel = callback;
      }
    }
    //private
    onDone(callback) {
      this._onDone = () => {
        this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
        callback();
      };
    }
    onElUpdated() {
      const activeRefs = this.fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
      if (activeRefs.indexOf(this.ref) === -1) {
        LiveUploader.untrackFile(this.fileEl, this.file);
        this.cancel();
      }
    }
    toPreflightPayload() {
      return {
        last_modified: this.file.lastModified,
        name: this.file.name,
        relative_path: this.file.webkitRelativePath,
        size: this.file.size,
        type: this.file.type,
        ref: this.ref,
        meta: typeof this.file.meta === "function" ? this.file.meta() : void 0
      };
    }
    uploader(uploaders) {
      if (this.meta.uploader) {
        const callback = uploaders[this.meta.uploader] || this.view.logError(
          "upload.missing-uploader",
          `no uploader configured for ${this.meta.uploader}`,
          { uploader: this.meta.uploader, uploaders }
        );
        return { name: this.meta.uploader, callback };
      } else {
        return { name: "channel", callback: channelUploader };
      }
    }
    zipPostFlight(resp) {
      this.meta = resp.entries[this.ref];
      if (!this.meta) {
        this.view.logError(
          "upload.missing-preflight-response",
          `no preflight upload response returned with ref ${this.ref}`,
          {
            ref: this.ref,
            input: this.fileEl,
            response: resp
          },
          { attribution: "internal" }
        );
      }
    }
  };
  var liveUploaderFileRef = 0;
  var LiveUploader = class _LiveUploader {
    static genFileRef(file) {
      const ref = file._phxRef;
      if (ref !== void 0) {
        return ref;
      } else {
        file._phxRef = (liveUploaderFileRef++).toString();
        return file._phxRef;
      }
    }
    static getEntryDataURL(inputEl, ref) {
      const file = this.activeFiles(inputEl).find(
        (file2) => this.genFileRef(file2) === ref
      );
      if (!file)
        return null;
      return URL.createObjectURL(file);
    }
    static hasUploadsInProgress(formEl) {
      let active = 0;
      dom_default.findUploadInputs(formEl).forEach((input) => {
        if (input.getAttribute(PHX_PREFLIGHTED_REFS) !== input.getAttribute(PHX_DONE_REFS)) {
          active++;
        }
      });
      return active > 0;
    }
    static hasUploadErrors(formEl) {
      return dom_default.findUploadInputs(formEl).some(
        (input) => (input.getAttribute(PHX_ERROR_REFS) || "") !== ""
      );
    }
    static serializeUploads(inputEl) {
      const files = this.activeFiles(inputEl);
      const fileData = {};
      files.forEach((file) => {
        const entry = { path: inputEl.name };
        const uploadRef = inputEl.getAttribute(PHX_UPLOAD_REF);
        fileData[uploadRef] = fileData[uploadRef] || [];
        entry.ref = this.genFileRef(file);
        entry.last_modified = file.lastModified;
        entry.name = file.name || entry.ref;
        entry.relative_path = file.webkitRelativePath;
        entry.type = file.type;
        entry.size = file.size;
        if (typeof file.meta === "function") {
          entry.meta = file.meta();
        }
        fileData[uploadRef].push(entry);
      });
      return fileData;
    }
    static clearFiles(inputEl) {
      inputEl.value = null;
      inputEl.removeAttribute(PHX_UPLOAD_REF);
      dom_default.putPrivate(inputEl, "files", []);
    }
    static untrackFile(inputEl, file) {
      dom_default.putPrivate(
        inputEl,
        "files",
        dom_default.private(inputEl, "files").filter((f2) => !Object.is(f2, file))
      );
    }
    /**
     * @param {HTMLInputElement} inputEl
     * @param {Array<File|Blob>} files
     * @param {DataTransfer} [dataTransfer]
     */
    static trackFiles(inputEl, files, dataTransfer) {
      if (inputEl.getAttribute("multiple") !== null) {
        const newFiles = files.filter(
          (file) => !this.activeFiles(inputEl).find((f2) => Object.is(f2, file))
        );
        dom_default.updatePrivate(
          inputEl,
          "files",
          [],
          (existing) => existing.concat(newFiles)
        );
        inputEl.value = "";
      } else {
        if (dataTransfer && dataTransfer.files.length > 0) {
          inputEl.files = dataTransfer.files;
        }
        dom_default.putPrivate(inputEl, "files", files);
      }
    }
    static activeFileInputs(formEl) {
      return dom_default.findUploadInputs(formEl).filter(
        (el) => el.files && this.activeFiles(el).length > 0
      );
    }
    static activeFiles(input) {
      return (dom_default.private(input, "files") || []).filter(
        (f2) => UploadEntry.isActive(input, f2)
      );
    }
    static inputsAwaitingPreflight(formEl) {
      return dom_default.findUploadInputs(formEl).filter(
        (input) => this.filesAwaitingPreflight(input).length > 0
      );
    }
    static filesAwaitingPreflight(input) {
      return this.activeFiles(input).filter(
        (f2) => !UploadEntry.isPreflighted(input, f2) && !UploadEntry.isPreflightInProgress(f2)
      );
    }
    static markPreflightInProgress(entries) {
      entries.forEach((entry) => UploadEntry.markPreflightInProgress(entry.file));
    }
    constructor(inputEl, view, onComplete) {
      this.autoUpload = dom_default.isAutoUpload(inputEl);
      this.view = view;
      this.onComplete = onComplete;
      this._entries = Array.from(
        _LiveUploader.filesAwaitingPreflight(inputEl) || []
      ).map((file) => new UploadEntry(inputEl, file, view, this.autoUpload));
      _LiveUploader.markPreflightInProgress(this._entries);
      this.numEntriesInProgress = this._entries.length;
    }
    isAutoUpload() {
      return this.autoUpload;
    }
    entries() {
      return this._entries;
    }
    cancel() {
      this._entries.filter((entry) => !entry.isDone()).forEach((entry) => entry.cancel());
    }
    initAdapterUpload(resp, onError, liveSocket2) {
      this._entries = this._entries.map((entry) => {
        if (entry.isCancelled()) {
          this.numEntriesInProgress--;
          if (this.numEntriesInProgress === 0) {
            this.onComplete();
          }
        } else {
          entry.zipPostFlight(resp);
          entry.onDone(() => {
            this.numEntriesInProgress--;
            if (this.numEntriesInProgress === 0) {
              this.onComplete();
            }
          });
        }
        return entry;
      });
      const groupedEntries = this._entries.reduce((acc, entry) => {
        if (!entry.meta) {
          return acc;
        }
        const { name, callback } = entry.uploader(liveSocket2.uploaders);
        acc[name] = acc[name] || { callback, entries: [] };
        acc[name].entries.push(entry);
        return acc;
      }, {});
      for (const name in groupedEntries) {
        const { callback, entries } = groupedEntries[name];
        callback(entries, onError, resp, liveSocket2);
      }
    }
  };
  var ARIA = {
    anyOf(instance, classes) {
      return classes.some((name) => instance instanceof name);
    },
    isFocusable(el, interactiveOnly = false) {
      return el instanceof HTMLAnchorElement && el.rel !== "ignore" || el instanceof HTMLAreaElement && el.href !== void 0 || !("disabled" in el && el.disabled) && this.anyOf(el, [
        HTMLInputElement,
        HTMLSelectElement,
        HTMLTextAreaElement,
        HTMLButtonElement
      ]) || el instanceof HTMLIFrameElement || el instanceof HTMLElement && el.tabIndex >= 0 && el.getAttribute("aria-hidden") !== "true" || !interactiveOnly && el.getAttribute("tabindex") !== null && el.getAttribute("aria-hidden") !== "true";
    },
    attemptFocus(el, interactiveOnly = false) {
      if (this.isFocusable(el, interactiveOnly)) {
        try {
          el.focus();
        } catch (e2) {
        }
      }
      return !!document.activeElement && document.activeElement.isSameNode(el);
    },
    focusFirstInteractive(el) {
      let child = el.firstElementChild;
      while (child) {
        if (this.attemptFocus(child, true) || this.focusFirstInteractive(child)) {
          return true;
        }
        child = child.nextElementSibling;
      }
      return false;
    },
    focusFirst(el) {
      let child = el.firstElementChild;
      while (child) {
        if (this.attemptFocus(child) || this.focusFirst(child)) {
          return true;
        }
        child = child.nextElementSibling;
      }
      return false;
    },
    focusLast(el) {
      let child = el.lastElementChild;
      while (child) {
        if (this.attemptFocus(child) || this.focusLast(child)) {
          return true;
        }
        child = child.previousElementSibling;
      }
      return false;
    }
  };
  var aria_default = ARIA;
  var findScrollContainer = (el) => {
    if (["HTML", "BODY"].indexOf(el.nodeName.toUpperCase()) >= 0)
      return null;
    if (["scroll", "auto"].indexOf(getComputedStyle(el).overflowY) >= 0)
      return el;
    return findScrollContainer(el.parentElement);
  };
  var scrollTop = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.scrollTop;
    } else {
      return document.documentElement.scrollTop || document.body.scrollTop;
    }
  };
  var bottom = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.getBoundingClientRect().bottom;
    } else {
      return window.innerHeight || document.documentElement.clientHeight;
    }
  };
  var top = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.getBoundingClientRect().top;
    } else {
      return 0;
    }
  };
  var isAtViewportTop = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.top) >= top(scrollContainer) && Math.floor(rect.top) <= bottom(scrollContainer);
  };
  var isAtViewportBottom = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.bottom) >= top(scrollContainer) && Math.floor(rect.bottom) <= bottom(scrollContainer);
  };
  var isWithinViewport = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.top) >= top(scrollContainer) && Math.floor(rect.top) <= bottom(scrollContainer);
  };
  var InfiniteScroll = {
    mounted() {
      this.scrollContainer = findScrollContainer(this.el);
      let scrollBefore = scrollTop(this.scrollContainer);
      let topOverran = false;
      const throttleInterval = 500;
      let pendingOp = null;
      const onTopOverrun = this.throttle(
        throttleInterval,
        (topEvent, firstChild) => {
          pendingOp = () => true;
          this.liveSocket.js().push(this.el, topEvent, {
            value: { id: firstChild.id, _overran: true },
            callback: () => {
              pendingOp = null;
            }
          });
        }
      );
      const onFirstChildAtTop = this.throttle(
        throttleInterval,
        (topEvent, firstChild) => {
          pendingOp = () => firstChild.scrollIntoView({ block: "start" });
          this.liveSocket.js().push(this.el, topEvent, {
            value: { id: firstChild.id },
            callback: () => {
              pendingOp = null;
              window.requestAnimationFrame(() => {
                if (!isWithinViewport(firstChild, this.scrollContainer)) {
                  firstChild.scrollIntoView({ block: "start" });
                }
              });
            }
          });
        }
      );
      const onLastChildAtBottom = this.throttle(
        throttleInterval,
        (bottomEvent, lastChild) => {
          pendingOp = () => lastChild.scrollIntoView({ block: "end" });
          this.liveSocket.js().push(this.el, bottomEvent, {
            value: { id: lastChild.id },
            callback: () => {
              pendingOp = null;
              window.requestAnimationFrame(() => {
                if (!isWithinViewport(lastChild, this.scrollContainer)) {
                  lastChild.scrollIntoView({ block: "end" });
                }
              });
            }
          });
        }
      );
      this.throttles = [onTopOverrun, onFirstChildAtTop, onLastChildAtBottom];
      this.onScroll = (_e2) => {
        const scrollNow = scrollTop(this.scrollContainer);
        if (pendingOp) {
          scrollBefore = scrollNow;
          return pendingOp();
        }
        const rect = this.findOverrunTarget();
        const topEvent = this.el.getAttribute(
          this.liveSocket.binding("viewport-top")
        );
        const bottomEvent = this.el.getAttribute(
          this.liveSocket.binding("viewport-bottom")
        );
        const lastChild = this.el.lastElementChild;
        const firstChild = this.el.firstElementChild;
        const isScrollingUp = scrollNow < scrollBefore;
        const isScrollingDown = scrollNow > scrollBefore;
        if (isScrollingUp && topEvent && !topOverran && rect.top >= 0) {
          topOverran = true;
          onTopOverrun(topEvent, firstChild);
        } else if (isScrollingDown && topOverran && rect.top <= 0) {
          topOverran = false;
        }
        if (topEvent && isScrollingUp && firstChild && isAtViewportTop(firstChild, this.scrollContainer)) {
          onFirstChildAtTop(topEvent, firstChild);
        } else if (bottomEvent && isScrollingDown && lastChild && isAtViewportBottom(lastChild, this.scrollContainer)) {
          onLastChildAtBottom(bottomEvent, lastChild);
        }
        scrollBefore = scrollNow;
      };
      if (this.scrollContainer) {
        this.scrollContainer.addEventListener("scroll", this.onScroll);
      } else {
        window.addEventListener("scroll", this.onScroll);
      }
    },
    updated() {
      if (this.scrollContainer && !this.scrollContainer.isConnected) {
        this.destroyed();
        this.mounted();
      }
    },
    destroyed() {
      var _a;
      (_a = this.throttles) == null ? void 0 : _a.forEach((throttled) => throttled.cancel());
      this.throttles = null;
      if (this.scrollContainer) {
        this.scrollContainer.removeEventListener("scroll", this.onScroll);
      } else {
        window.removeEventListener("scroll", this.onScroll);
      }
    },
    throttle(interval, callback) {
      let lastCallAt = 0;
      let timer = null;
      const throttled = (...args) => {
        const now = Date.now();
        const remainingTime = interval - (now - lastCallAt);
        if (remainingTime <= 0 || remainingTime > interval) {
          if (timer !== null) {
            clearTimeout(timer);
            timer = null;
          }
          lastCallAt = now;
          callback(...args);
        } else if (timer === null) {
          timer = setTimeout(() => {
            lastCallAt = Date.now();
            timer = null;
            callback(...args);
          }, remainingTime);
        }
      };
      throttled.cancel = () => {
        if (timer !== null) {
          clearTimeout(timer);
          timer = null;
        }
      };
      return throttled;
    },
    findOverrunTarget() {
      let rect;
      const overrunTarget = this.el.getAttribute(
        this.liveSocket.binding(PHX_VIEWPORT_OVERRUN_TARGET)
      );
      if (overrunTarget) {
        const overrunEl = document.getElementById(overrunTarget);
        if (overrunEl) {
          rect = overrunEl.getBoundingClientRect();
        } else {
          throw new Error("did not find element with id " + overrunTarget);
        }
      } else {
        rect = this.el.getBoundingClientRect();
      }
      return rect;
    }
  };
  var LiveFileUpload = {
    activeRefs() {
      return this.el.getAttribute(PHX_ACTIVE_ENTRY_REFS);
    },
    preflightedRefs() {
      return this.el.getAttribute(PHX_PREFLIGHTED_REFS);
    },
    errorRefs() {
      return this.el.getAttribute(PHX_ERROR_REFS) || "";
    },
    hasSelectedFiles() {
      var _a;
      return (((_a = this.el.files) == null ? void 0 : _a.length) || 0) > 0 || LiveUploader.activeFiles(this.el).length > 0 || this.activeRefs() !== "" || this.errorRefs() !== "";
    },
    maybeRemoveRequired() {
      if (this.hasSelectedFiles()) {
        this.el.removeAttribute("required");
      }
    },
    mounted() {
      this.js().ignoreAttributes(this.el, ["value"]);
      this.preflightedWas = this.preflightedRefs();
      this.errorRefsWas = this.errorRefs();
      this.el.addEventListener("input", () => this.maybeRemoveRequired());
      this.maybeRemoveRequired();
    },
    updated() {
      const newPreflights = this.preflightedRefs();
      const newErrorRefs = this.errorRefs();
      if (this.errorRefsWas !== newErrorRefs) {
        this.errorRefsWas = newErrorRefs;
        if (newErrorRefs !== "") {
          this.__view().cancelSubmit(this.el.form);
        }
      }
      if (this.preflightedWas !== newPreflights) {
        this.preflightedWas = newPreflights;
        if (newPreflights === "") {
          this.__view().cancelSubmit(this.el.form);
        }
      }
      if (this.activeRefs() === "") {
        this.el.value = "";
      }
      this.maybeRemoveRequired();
      this.el.dispatchEvent(new CustomEvent(PHX_LIVE_FILE_UPDATED));
    }
  };
  var LiveImgPreview = {
    mounted() {
      this.ref = this.el.getAttribute("data-phx-entry-ref");
      this.inputEl = document.getElementById(
        this.el.getAttribute(PHX_UPLOAD_REF)
      );
      this.url = LiveUploader.getEntryDataURL(this.inputEl, this.ref);
      this.el.src = this.url;
    },
    destroyed() {
      URL.revokeObjectURL(this.url);
    }
  };
  var Hooks = {
    LiveFileUpload,
    LiveImgPreview,
    FocusWrap: {
      mounted() {
        this.focusStart = this.el.firstElementChild;
        this.focusEnd = this.el.lastElementChild;
        this.focusStart.addEventListener("focus", (e2) => {
          if (!e2.relatedTarget || !this.el.contains(e2.relatedTarget)) {
            const nextFocus = e2.target.nextElementSibling;
            aria_default.attemptFocus(nextFocus) || aria_default.focusFirst(nextFocus);
          } else {
            aria_default.focusLast(this.el);
          }
        });
        this.focusEnd.addEventListener("focus", (e2) => {
          if (!e2.relatedTarget || !this.el.contains(e2.relatedTarget)) {
            const nextFocus = e2.target.previousElementSibling;
            aria_default.attemptFocus(nextFocus) || aria_default.focusLast(nextFocus);
          } else {
            aria_default.focusFirst(this.el);
          }
        });
        if (!this.el.contains(document.activeElement)) {
          this.el.addEventListener("phx:show-end", () => this.el.focus());
          if (window.getComputedStyle(this.el).display !== "none") {
            aria_default.focusFirst(this.el);
          }
        }
      }
    },
    InfiniteScroll
  };
  var hooks_default = Hooks;
  var ElementRef = class {
    static onUnlock(el, callback) {
      const closestLock = el.closest(`[${PHX_REF_LOCK}]`);
      if (!closestLock) {
        return callback();
      }
      const ref = closestLock.getAttribute(PHX_REF_LOCK);
      closestLock.addEventListener(
        `phx:undo-lock:${ref}`,
        () => {
          callback();
        },
        { once: true }
      );
    }
    constructor(el) {
      this.el = el;
      this.loadingRef = el.hasAttribute(PHX_REF_LOADING) ? parseInt(el.getAttribute(PHX_REF_LOADING), 10) : null;
      this.lockRef = el.hasAttribute(PHX_REF_LOCK) ? parseInt(el.getAttribute(PHX_REF_LOCK), 10) : null;
    }
    // public
    maybeUndo(ref, phxEvent, eachCloneCallback) {
      if (!this.isWithin(ref)) {
        dom_default.updatePrivate(this.el, PHX_PENDING_REFS, [], (pendingRefs) => {
          pendingRefs.push(ref);
          return pendingRefs;
        });
        return;
      }
      this.undoLocks(ref, phxEvent, eachCloneCallback);
      this.undoLoading(ref, phxEvent);
      dom_default.updatePrivate(this.el, PHX_PENDING_REFS, [], (pendingRefs) => {
        return pendingRefs.filter((pendingRef) => {
          let opts = {
            detail: { ref: pendingRef, event: phxEvent },
            bubbles: true,
            cancelable: false
          };
          if (this.loadingRef && this.loadingRef > pendingRef) {
            this.el.dispatchEvent(
              new CustomEvent(`phx:undo-loading:${pendingRef}`, opts)
            );
          }
          if (this.lockRef && this.lockRef > pendingRef) {
            this.el.dispatchEvent(
              new CustomEvent(`phx:undo-lock:${pendingRef}`, opts)
            );
          }
          return pendingRef > ref;
        });
      });
      if (this.isFullyResolvedBy(ref)) {
        this.el.removeAttribute(PHX_REF_SRC);
      }
    }
    // private
    isWithin(ref) {
      return !(this.loadingRef !== null && this.loadingRef > ref && this.lockRef !== null && this.lockRef > ref);
    }
    // Check for cloned PHX_REF_LOCK element that has been morphed behind
    // the scenes while this element was locked in the DOM.
    // When we apply the cloned tree to the active DOM element, we must
    //
    //   1. execute pending mounted hooks for nodes now in the DOM
    //   2. undo any ref inside the cloned tree that has since been ack'd
    undoLocks(ref, phxEvent, eachCloneCallback) {
      if (!this.isLockUndoneBy(ref)) {
        return;
      }
      const clonedTree = dom_default.private(this.el, PHX_REF_LOCK);
      if (clonedTree) {
        eachCloneCallback(clonedTree);
        dom_default.deletePrivate(this.el, PHX_REF_LOCK);
      }
      this.el.removeAttribute(PHX_REF_LOCK);
      const opts = {
        detail: { ref, event: phxEvent },
        bubbles: true,
        cancelable: false
      };
      this.el.dispatchEvent(
        new CustomEvent(`phx:undo-lock:${this.lockRef}`, opts)
      );
    }
    undoLoading(ref, phxEvent) {
      if (!this.isLoadingUndoneBy(ref)) {
        if (this.canUndoLoading(ref) && this.el.classList.contains("phx-submit-loading")) {
          this.el.classList.remove("phx-change-loading");
        }
        return;
      }
      if (this.canUndoLoading(ref)) {
        this.el.removeAttribute(PHX_REF_LOADING);
        const disabledVal = this.el.getAttribute(PHX_DISABLED);
        const readOnlyVal = this.el.getAttribute(PHX_READONLY);
        if (readOnlyVal !== null && "readOnly" in this.el) {
          this.el.readOnly = readOnlyVal === "true" ? true : false;
          this.el.removeAttribute(PHX_READONLY);
        }
        if (disabledVal !== null && "disabled" in this.el) {
          this.el.disabled = disabledVal === "true" ? true : false;
          this.el.removeAttribute(PHX_DISABLED);
        }
        const disableRestore = this.el.getAttribute(PHX_DISABLE_WITH_RESTORE);
        if (disableRestore !== null) {
          this.el.textContent = disableRestore;
          this.el.removeAttribute(PHX_DISABLE_WITH_RESTORE);
        }
        const opts = {
          detail: { ref, event: phxEvent },
          bubbles: true,
          cancelable: false
        };
        this.el.dispatchEvent(
          new CustomEvent(`phx:undo-loading:${this.loadingRef}`, opts)
        );
      }
      PHX_EVENT_CLASSES.forEach((name) => {
        if (name !== "phx-submit-loading" || this.canUndoLoading(ref)) {
          dom_default.removeClass(this.el, name);
        }
      });
    }
    isLoadingUndoneBy(ref) {
      return this.loadingRef === null ? false : this.loadingRef <= ref;
    }
    /** @internal */
    isLockUndoneBy(ref) {
      return this.lockRef === null ? false : this.lockRef <= ref;
    }
    isFullyResolvedBy(ref) {
      return (this.loadingRef === null || this.loadingRef <= ref) && (this.lockRef === null || this.lockRef <= ref);
    }
    // only remove the phx-submit-loading class if we are not locked
    canUndoLoading(ref) {
      return this.lockRef === null || this.lockRef <= ref;
    }
  };
  var DOMPostMorphRestorer = class {
    constructor(containerBefore, containerAfter, updateType) {
      const idsBefore = /* @__PURE__ */ new Set();
      const idsAfter = new Set(
        [...containerAfter.children].map((child) => child.id)
      );
      const elementsToModify = [];
      Array.from(containerBefore.children).forEach((child) => {
        if (child.id) {
          idsBefore.add(child.id);
          if (idsAfter.has(child.id)) {
            const previousElementId = child.previousElementSibling && child.previousElementSibling.id;
            elementsToModify.push({
              elementId: child.id,
              previousElementId
            });
          }
        }
      });
      this.containerId = containerAfter.id;
      this.updateType = updateType;
      this.elementsToModify = elementsToModify;
      this.elementIdsToAdd = [...idsAfter].filter((id) => !idsBefore.has(id));
    }
    // We do the following to optimize append/prepend operations:
    //   1) Track ids of modified elements & of new elements
    //   2) All the modified elements are put back in the correct position in the DOM tree
    //      by storing the id of their previous sibling
    //   3) New elements are going to be put in the right place by morphdom during append.
    //      For prepend, we move them to the first position in the container
    perform() {
      const container = dom_default.byId(this.containerId);
      if (!container) {
        return;
      }
      this.elementsToModify.forEach((elementToModify) => {
        if (elementToModify.previousElementId) {
          maybe(
            document.getElementById(elementToModify.previousElementId),
            (previousElem) => {
              maybe(
                document.getElementById(elementToModify.elementId),
                (elem) => {
                  const isInRightPlace = elem.previousElementSibling && elem.previousElementSibling.id == previousElem.id;
                  if (!isInRightPlace) {
                    previousElem.insertAdjacentElement("afterend", elem);
                  }
                }
              );
            }
          );
        } else {
          maybe(document.getElementById(elementToModify.elementId), (elem) => {
            const isInRightPlace = elem.previousElementSibling == null;
            if (!isInRightPlace) {
              container.insertAdjacentElement("afterbegin", elem);
            }
          });
        }
      });
      if (this.updateType == "prepend") {
        this.elementIdsToAdd.reverse().forEach((elemId) => {
          maybe(
            document.getElementById(elemId),
            (elem) => container.insertAdjacentElement("afterbegin", elem)
          );
        });
      }
    }
  };
  var DOCUMENT_FRAGMENT_NODE = 11;
  function morphAttrs(fromNode, toNode) {
    var toNodeAttrs = toNode.attributes;
    var attr;
    var attrName;
    var attrNamespaceURI;
    var attrValue;
    var fromValue;
    if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE || fromNode.nodeType === DOCUMENT_FRAGMENT_NODE) {
      return;
    }
    for (var i = toNodeAttrs.length - 1; i >= 0; i--) {
      attr = toNodeAttrs[i];
      attrName = attr.name;
      attrNamespaceURI = attr.namespaceURI;
      attrValue = attr.value;
      if (attrNamespaceURI) {
        attrName = attr.localName || attrName;
        fromValue = fromNode.getAttributeNS(attrNamespaceURI, attrName);
        if (fromValue !== attrValue) {
          if (attr.prefix === "xmlns") {
            attrName = attr.name;
          }
          fromNode.setAttributeNS(attrNamespaceURI, attrName, attrValue);
        }
      } else {
        fromValue = fromNode.getAttribute(attrName);
        if (fromValue !== attrValue) {
          fromNode.setAttribute(attrName, attrValue);
        }
      }
    }
    var fromNodeAttrs = fromNode.attributes;
    for (var d2 = fromNodeAttrs.length - 1; d2 >= 0; d2--) {
      attr = fromNodeAttrs[d2];
      attrName = attr.name;
      attrNamespaceURI = attr.namespaceURI;
      if (attrNamespaceURI) {
        attrName = attr.localName || attrName;
        if (!toNode.hasAttributeNS(attrNamespaceURI, attrName)) {
          fromNode.removeAttributeNS(attrNamespaceURI, attrName);
        }
      } else {
        if (!toNode.hasAttribute(attrName)) {
          fromNode.removeAttribute(attrName);
        }
      }
    }
  }
  var range;
  var NS_XHTML = "http://www.w3.org/1999/xhtml";
  var doc = typeof document === "undefined" ? void 0 : document;
  var HAS_TEMPLATE_SUPPORT = !!doc && "content" in doc.createElement("template");
  var HAS_RANGE_SUPPORT = !!doc && doc.createRange && "createContextualFragment" in doc.createRange();
  function createFragmentFromTemplate(str) {
    var template = doc.createElement("template");
    template.innerHTML = str;
    return template.content.childNodes[0];
  }
  function createFragmentFromRange(str) {
    if (!range) {
      range = doc.createRange();
      range.selectNode(doc.body);
    }
    var fragment = range.createContextualFragment(str);
    return fragment.childNodes[0];
  }
  function createFragmentFromWrap(str) {
    var fragment = doc.createElement("body");
    fragment.innerHTML = str;
    return fragment.childNodes[0];
  }
  function toElement(str) {
    str = str.trim();
    if (HAS_TEMPLATE_SUPPORT) {
      return createFragmentFromTemplate(str);
    } else if (HAS_RANGE_SUPPORT) {
      return createFragmentFromRange(str);
    }
    return createFragmentFromWrap(str);
  }
  function compareNodeNames(fromEl, toEl) {
    var fromNodeName = fromEl.nodeName;
    var toNodeName = toEl.nodeName;
    var fromCodeStart, toCodeStart;
    if (fromNodeName === toNodeName) {
      return true;
    }
    fromCodeStart = fromNodeName.charCodeAt(0);
    toCodeStart = toNodeName.charCodeAt(0);
    if (fromCodeStart <= 90 && toCodeStart >= 97) {
      return fromNodeName === toNodeName.toUpperCase();
    } else if (toCodeStart <= 90 && fromCodeStart >= 97) {
      return toNodeName === fromNodeName.toUpperCase();
    } else {
      return false;
    }
  }
  function createElementNS(name, namespaceURI) {
    return !namespaceURI || namespaceURI === NS_XHTML ? doc.createElement(name) : doc.createElementNS(namespaceURI, name);
  }
  function moveChildren(fromEl, toEl) {
    var curChild = fromEl.firstChild;
    while (curChild) {
      var nextChild = curChild.nextSibling;
      toEl.appendChild(curChild);
      curChild = nextChild;
    }
    return toEl;
  }
  function syncBooleanAttrProp(fromEl, toEl, name) {
    if (fromEl[name] !== toEl[name]) {
      fromEl[name] = toEl[name];
      if (fromEl[name]) {
        fromEl.setAttribute(name, "");
      } else {
        fromEl.removeAttribute(name);
      }
    }
  }
  var specialElHandlers_default = {
    OPTION: function(fromEl, toEl) {
      var parentNode = fromEl.parentNode;
      if (parentNode) {
        var parentName = parentNode.nodeName.toUpperCase();
        if (parentName === "OPTGROUP") {
          parentNode = parentNode.parentNode;
          parentName = parentNode && parentNode.nodeName.toUpperCase();
        }
        if (parentName === "SELECT" && !parentNode.hasAttribute("multiple")) {
          if (fromEl.hasAttribute("selected") && !toEl.selected) {
            fromEl.setAttribute("selected", "selected");
            fromEl.removeAttribute("selected");
          }
          parentNode.selectedIndex = -1;
        }
      }
      syncBooleanAttrProp(fromEl, toEl, "selected");
    },
    /**
     * The "value" attribute is special for the <input> element since it sets
     * the initial value. Changing the "value" attribute without changing the
     * "value" property will have no effect since it is only used to the set the
     * initial value.  Similar for the "checked" attribute, and "disabled".
     */
    INPUT: function(fromEl, toEl) {
      syncBooleanAttrProp(fromEl, toEl, "checked");
      syncBooleanAttrProp(fromEl, toEl, "disabled");
      if (fromEl.value !== toEl.value) {
        fromEl.value = toEl.value;
      }
      if (!toEl.hasAttribute("value")) {
        fromEl.removeAttribute("value");
      }
    },
    TEXTAREA: function(fromEl, toEl) {
      var newValue = toEl.value;
      if (fromEl.value !== newValue) {
        fromEl.value = newValue;
      }
      var firstChild = fromEl.firstChild;
      if (firstChild) {
        var oldValue = firstChild.nodeValue;
        if (oldValue == newValue || !newValue && oldValue == fromEl.placeholder) {
          return;
        }
        firstChild.nodeValue = newValue;
      }
    },
    SELECT: function(fromEl, toEl) {
      if (!toEl.hasAttribute("multiple")) {
        var selectedIndex = -1;
        var i = 0;
        var curChild = fromEl.firstChild;
        var optgroup;
        var nodeName;
        while (curChild) {
          nodeName = curChild.nodeName && curChild.nodeName.toUpperCase();
          if (nodeName === "OPTGROUP") {
            optgroup = curChild;
            curChild = optgroup.firstChild;
            if (!curChild) {
              curChild = optgroup.nextSibling;
              optgroup = null;
            }
          } else {
            if (nodeName === "OPTION") {
              if (curChild.hasAttribute("selected")) {
                selectedIndex = i;
                break;
              }
              i++;
            }
            curChild = curChild.nextSibling;
            if (!curChild && optgroup) {
              curChild = optgroup.nextSibling;
              optgroup = null;
            }
          }
        }
        fromEl.selectedIndex = selectedIndex;
      }
    }
  };
  var ELEMENT_NODE = 1;
  var DOCUMENT_FRAGMENT_NODE2 = 11;
  var TEXT_NODE = 3;
  var COMMENT_NODE = 8;
  function noop() {
  }
  function defaultGetNodeKey(node) {
    if (node) {
      return node.getAttribute && node.getAttribute("id") || node.id;
    }
  }
  function morphdomFactory(morphAttrs2) {
    return function morphdom2(fromNode, toNode, options) {
      if (!options) {
        options = {};
      }
      if (typeof toNode === "string") {
        if (fromNode.nodeName === "#document" || fromNode.nodeName === "HTML") {
          var toNodeHtml = toNode;
          toNode = doc.createElement("html");
          toNode.innerHTML = toNodeHtml;
        } else if (fromNode.nodeName === "BODY") {
          var toNodeBody = toNode;
          toNode = doc.createElement("html");
          toNode.innerHTML = toNodeBody;
          var bodyElement = toNode.querySelector("body");
          if (bodyElement) {
            toNode = bodyElement;
          }
        } else {
          toNode = toElement(toNode);
        }
      } else if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE2) {
        toNode = toNode.firstElementChild;
      }
      var getNodeKey = options.getNodeKey || defaultGetNodeKey;
      var onBeforeNodeAdded = options.onBeforeNodeAdded || noop;
      var onNodeAdded = options.onNodeAdded || noop;
      var onBeforeElUpdated = options.onBeforeElUpdated || noop;
      var onElUpdated = options.onElUpdated || noop;
      var onBeforeNodeDiscarded = options.onBeforeNodeDiscarded || noop;
      var onNodeDiscarded = options.onNodeDiscarded || noop;
      var onBeforeElChildrenUpdated = options.onBeforeElChildrenUpdated || noop;
      var skipFromChildren = options.skipFromChildren || noop;
      var addChild = options.addChild || function(parent, child) {
        return parent.appendChild(child);
      };
      var childrenOnly = options.childrenOnly === true;
      var keyedRoot = options.keyedRoot === true;
      var fromNodesLookup = /* @__PURE__ */ Object.create(null);
      var keyedRemovalList = [];
      function addKeyedRemoval(key) {
        keyedRemovalList.push(key);
      }
      function walkDiscardedChildNodes(node, skipKeyedNodes) {
        if (node.nodeType === ELEMENT_NODE) {
          var curChild = node.firstChild;
          while (curChild) {
            var key = void 0;
            if (skipKeyedNodes && (key = getNodeKey(curChild))) {
              addKeyedRemoval(key);
            } else {
              onNodeDiscarded(curChild);
              if (curChild.firstChild) {
                walkDiscardedChildNodes(curChild, skipKeyedNodes);
              }
            }
            curChild = curChild.nextSibling;
          }
        }
      }
      function removeNode(node, parentNode, skipKeyedNodes) {
        if (onBeforeNodeDiscarded(node) === false) {
          return;
        }
        if (parentNode) {
          parentNode.removeChild(node);
        }
        onNodeDiscarded(node);
        walkDiscardedChildNodes(node, skipKeyedNodes);
      }
      function indexTree(node) {
        if (node.nodeType === ELEMENT_NODE || node.nodeType === DOCUMENT_FRAGMENT_NODE2) {
          var curChild = node.firstChild;
          while (curChild) {
            var key = getNodeKey(curChild);
            if (key) {
              fromNodesLookup[key] = curChild;
            }
            indexTree(curChild);
            curChild = curChild.nextSibling;
          }
        }
      }
      indexTree(fromNode);
      function handleNodeAdded(el) {
        onNodeAdded(el);
        var curChild = el.firstChild;
        while (curChild) {
          var nextSibling = curChild.nextSibling;
          var key = getNodeKey(curChild);
          if (key) {
            var unmatchedFromEl = fromNodesLookup[key];
            if (unmatchedFromEl && compareNodeNames(curChild, unmatchedFromEl)) {
              curChild.parentNode.replaceChild(unmatchedFromEl, curChild);
              morphEl(unmatchedFromEl, curChild);
            } else {
              handleNodeAdded(curChild);
            }
          } else {
            handleNodeAdded(curChild);
          }
          curChild = nextSibling;
        }
      }
      function cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey) {
        while (curFromNodeChild) {
          var fromNextSibling = curFromNodeChild.nextSibling;
          if (curFromNodeKey = getNodeKey(curFromNodeChild)) {
            addKeyedRemoval(curFromNodeKey);
          } else {
            removeNode(
              curFromNodeChild,
              fromEl,
              true
              /* skip keyed nodes */
            );
          }
          curFromNodeChild = fromNextSibling;
        }
      }
      function morphEl(fromEl, toEl, childrenOnly2) {
        var toElKey = getNodeKey(toEl);
        if (toElKey) {
          delete fromNodesLookup[toElKey];
        }
        if (!childrenOnly2) {
          var beforeUpdateResult = onBeforeElUpdated(fromEl, toEl);
          if (beforeUpdateResult === false) {
            return;
          } else if (beforeUpdateResult instanceof HTMLElement) {
            fromEl = beforeUpdateResult;
            indexTree(fromEl);
          }
          morphAttrs2(fromEl, toEl);
          onElUpdated(fromEl);
          if (onBeforeElChildrenUpdated(fromEl, toEl) === false) {
            return;
          }
        }
        if (fromEl.nodeName !== "TEXTAREA") {
          morphChildren(fromEl, toEl);
        } else {
          specialElHandlers_default.TEXTAREA(fromEl, toEl);
        }
      }
      function morphChildren(fromEl, toEl) {
        var skipFrom = skipFromChildren(fromEl, toEl);
        var curToNodeChild = toEl.firstChild;
        var curFromNodeChild = fromEl.firstChild;
        var curToNodeKey;
        var curFromNodeKey;
        var fromNextSibling;
        var toNextSibling;
        var matchingFromEl;
        outer:
          while (curToNodeChild) {
            toNextSibling = curToNodeChild.nextSibling;
            curToNodeKey = getNodeKey(curToNodeChild);
            while (!skipFrom && curFromNodeChild) {
              fromNextSibling = curFromNodeChild.nextSibling;
              if (curToNodeChild.isSameNode && curToNodeChild.isSameNode(curFromNodeChild)) {
                curToNodeChild = toNextSibling;
                curFromNodeChild = fromNextSibling;
                continue outer;
              }
              curFromNodeKey = getNodeKey(curFromNodeChild);
              var curFromNodeType = curFromNodeChild.nodeType;
              var isCompatible = void 0;
              if (curFromNodeType === curToNodeChild.nodeType) {
                if (curFromNodeType === ELEMENT_NODE) {
                  if (curToNodeKey) {
                    if (curToNodeKey !== curFromNodeKey) {
                      if (matchingFromEl = fromNodesLookup[curToNodeKey]) {
                        if (fromNextSibling === matchingFromEl) {
                          isCompatible = false;
                        } else {
                          fromEl.insertBefore(matchingFromEl, curFromNodeChild);
                          if (curFromNodeKey) {
                            addKeyedRemoval(curFromNodeKey);
                          } else {
                            removeNode(
                              curFromNodeChild,
                              fromEl,
                              true
                              /* skip keyed nodes */
                            );
                          }
                          curFromNodeChild = matchingFromEl;
                          curFromNodeKey = getNodeKey(curFromNodeChild);
                        }
                      } else {
                        isCompatible = false;
                      }
                    }
                  } else if (curFromNodeKey) {
                    isCompatible = false;
                  }
                  isCompatible = isCompatible !== false && compareNodeNames(curFromNodeChild, curToNodeChild);
                  if (isCompatible) {
                    morphEl(curFromNodeChild, curToNodeChild);
                  }
                } else if (curFromNodeType === TEXT_NODE || curFromNodeType == COMMENT_NODE) {
                  isCompatible = true;
                  if (curFromNodeChild.nodeValue !== curToNodeChild.nodeValue) {
                    curFromNodeChild.nodeValue = curToNodeChild.nodeValue;
                  }
                }
              }
              if (isCompatible) {
                curToNodeChild = toNextSibling;
                curFromNodeChild = fromNextSibling;
                continue outer;
              }
              if (curFromNodeKey) {
                addKeyedRemoval(curFromNodeKey);
              } else {
                removeNode(
                  curFromNodeChild,
                  fromEl,
                  true
                  /* skip keyed nodes */
                );
              }
              curFromNodeChild = fromNextSibling;
            }
            if (curToNodeKey && (matchingFromEl = fromNodesLookup[curToNodeKey]) && compareNodeNames(matchingFromEl, curToNodeChild)) {
              if (!skipFrom) {
                addChild(fromEl, matchingFromEl);
              }
              morphEl(matchingFromEl, curToNodeChild);
            } else {
              var onBeforeNodeAddedResult = onBeforeNodeAdded(curToNodeChild);
              if (onBeforeNodeAddedResult !== false) {
                if (onBeforeNodeAddedResult) {
                  curToNodeChild = onBeforeNodeAddedResult;
                }
                if (curToNodeChild.actualize) {
                  curToNodeChild = curToNodeChild.actualize(fromEl.ownerDocument || doc);
                }
                addChild(fromEl, curToNodeChild);
                handleNodeAdded(curToNodeChild);
              }
            }
            curToNodeChild = toNextSibling;
            curFromNodeChild = fromNextSibling;
          }
        cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey);
        var specialElHandler = specialElHandlers_default[fromEl.nodeName];
        if (specialElHandler) {
          specialElHandler(fromEl, toEl);
        }
      }
      function cleanupKeyedNodes() {
        for (var i = 0, len = keyedRemovalList.length; i < len; i++) {
          var elToRemove = fromNodesLookup[keyedRemovalList[i]];
          if (elToRemove) {
            removeNode(elToRemove, elToRemove.parentNode, false);
          }
        }
      }
      if (keyedRoot && !childrenOnly) {
        var fromNodeKey = getNodeKey(fromNode);
        var toNodeKey = getNodeKey(toNode);
        if ((fromNodeKey || toNodeKey) && fromNodeKey !== toNodeKey) {
          if (toNode.actualize) {
            toNode = toNode.actualize(fromNode.ownerDocument || doc);
          }
          onNodeDiscarded(fromNode);
          if (fromNode.parentNode) {
            fromNode.parentNode.replaceChild(toNode, fromNode);
          }
          handleNodeAdded(toNode);
          walkDiscardedChildNodes(fromNode, false);
          cleanupKeyedNodes();
          return toNode;
        }
      }
      var morphedNode = fromNode;
      var morphedNodeType = morphedNode.nodeType;
      var toNodeType = toNode.nodeType;
      if (!childrenOnly) {
        if (morphedNodeType === ELEMENT_NODE) {
          if (toNodeType === ELEMENT_NODE) {
            if (!compareNodeNames(fromNode, toNode)) {
              onNodeDiscarded(fromNode);
              morphedNode = moveChildren(fromNode, createElementNS(toNode.nodeName, toNode.namespaceURI));
            }
          } else {
            morphedNode = toNode;
          }
        } else if (morphedNodeType === TEXT_NODE || morphedNodeType === COMMENT_NODE) {
          if (toNodeType === morphedNodeType) {
            if (morphedNode.nodeValue !== toNode.nodeValue) {
              morphedNode.nodeValue = toNode.nodeValue;
            }
            return morphedNode;
          } else {
            morphedNode = toNode;
          }
        }
      }
      if (morphedNode === toNode) {
        onNodeDiscarded(fromNode);
      } else {
        if (toNode.isSameNode && toNode.isSameNode(morphedNode)) {
          return;
        }
        morphEl(morphedNode, toNode, childrenOnly);
        cleanupKeyedNodes();
      }
      if (!childrenOnly && morphedNode !== fromNode && fromNode.parentNode) {
        if (morphedNode.actualize) {
          morphedNode = morphedNode.actualize(fromNode.ownerDocument || doc);
        }
        fromNode.parentNode.replaceChild(morphedNode, fromNode);
      }
      return morphedNode;
    };
  }
  var morphdom = morphdomFactory(morphAttrs);
  var index_default = morphdom;
  var DOMPatch = class {
    constructor(view, container, html, streams, targetCID, opts = {}) {
      var _a;
      this.view = view;
      this.liveSocket = view.liveSocket;
      this.container = container;
      this.rootID = view.root.id;
      this.html = html;
      this.streams = streams;
      this.streamInserts = {};
      this.streamComponentRestore = {};
      this.targetCID = targetCID;
      this.pendingRemoves = [];
      this.phxRemove = this.liveSocket.binding("remove");
      this.targetContainer = targetCID ? dom_default.getComponent(this.view.id, targetCID) : container;
      this.beforeUpdatedCallbacks = [];
      this.afterAddedCallbacks = [];
      this.afterUpdatedCallbacks = [];
      this.afterPhxChildAddedCallbacks = [];
      this.afterDiscardedCallbacks = [];
      this.afterTransitionsDiscardedCallbacks = [];
      this.withChildren = opts.withChildren || opts.undoRef !== void 0 || false;
      this.undoRef = (_a = opts.undoRef) != null ? _a : null;
    }
    beforeUpdated(callback) {
      this.beforeUpdatedCallbacks.push(callback);
    }
    afterAdded(callback) {
      this.afterAddedCallbacks.push(callback);
    }
    afterUpdated(callback) {
      this.afterUpdatedCallbacks.push(callback);
    }
    afterPhxChildAdded(callback) {
      this.afterPhxChildAddedCallbacks.push(callback);
    }
    afterDiscarded(callback) {
      this.afterDiscardedCallbacks.push(callback);
    }
    afterTransitionsDiscarded(callback) {
      this.afterTransitionsDiscardedCallbacks.push(callback);
    }
    markPrunableContentForRemoval() {
      const phxUpdate = this.liveSocket.binding(PHX_UPDATE);
      dom_default.all(
        this.container,
        `[${phxUpdate}=append] > *, [${phxUpdate}=prepend] > *`,
        (el) => {
          el.setAttribute(PHX_PRUNE, "");
        }
      );
    }
    perform(isJoinPatch) {
      const { view, liveSocket: liveSocket2, html, container } = this;
      const reportError = (code, message, metadata, context) => view.logError(code, message, metadata, context);
      let targetContainer = this.targetContainer;
      if (this.targetCID) {
        const closestLock = targetContainer.closest(`[${PHX_REF_LOCK}]`);
        if (closestLock && !closestLock.isSameNode(targetContainer) && view.ownsElement(closestLock)) {
          const clonedTree = dom_default.private(closestLock, PHX_REF_LOCK);
          if (clonedTree) {
            targetContainer = clonedTree.querySelector(
              `[data-phx-component="${this.targetCID}"]`
            );
            if (!targetContainer)
              return;
          }
        }
      }
      const focused = liveSocket2.getActiveElement();
      const { selectionStart, selectionEnd } = focused && dom_default.hasSelectionRange(focused) ? focused : {};
      const phxUpdate = liveSocket2.binding(PHX_UPDATE);
      const phxViewportTop = liveSocket2.binding(PHX_VIEWPORT_TOP);
      const phxViewportBottom = liveSocket2.binding(PHX_VIEWPORT_BOTTOM);
      const phxTriggerExternal = liveSocket2.binding(PHX_TRIGGER_ACTION);
      const phxPatchFocused = liveSocket2.binding(PHX_PATCH_FOCUSED);
      const added = [];
      const updates = [];
      const appendPrependUpdates = [];
      let portalCallbacks = [];
      let externalFormTriggered = null;
      const morph = (targetContainer2, source, withChildren = this.withChildren) => {
        const morphCallbacks = {
          // normally, we are running with childrenOnly, as the patch HTML for a LV
          // does not include the LV attrs (data-phx-session, etc.)
          // when we are patching a live component, we do want to patch the root element as well;
          // another case is the recursive patch of a stream item that was kept on reset (-> onBeforeNodeAdded)
          childrenOnly: targetContainer2.getAttribute(PHX_COMPONENT) === null && !withChildren,
          keyedRoot: targetContainer2.getAttribute(PHX_COMPONENT) != null,
          getNodeKey: (node) => {
            if (!(node instanceof Element))
              return null;
            if (dom_default.isPhxDestroyed(node)) {
              return null;
            }
            if (isJoinPatch) {
              return node.id;
            }
            if (dom_default.private(node, "clientsideIdAttribute")) {
              return node.getAttribute(PHX_MAGIC_ID);
            }
            return node.id || node.getAttribute(PHX_MAGIC_ID);
          },
          // skip indexing from children when container is stream
          skipFromChildren: (from) => {
            return from.getAttribute(phxUpdate) === PHX_STREAM;
          },
          // tell morphdom how to add a child
          addChild: (parent, child) => {
            var _a;
            const { ref, streamAt } = this.getStreamInsert(child);
            if (ref === void 0) {
              return parent.appendChild(child);
            }
            this.setStreamRef(child, ref);
            if (streamAt === 0) {
              parent.insertAdjacentElement("afterbegin", child);
            } else if (streamAt === -1) {
              const lastChild = parent.lastElementChild;
              if (lastChild && !lastChild.hasAttribute(PHX_STREAM_REF)) {
                const nonStreamChild = parent.querySelector(
                  `:scope > :not([${PHX_STREAM_REF}])`
                );
                parent.insertBefore(child, nonStreamChild);
              } else {
                parent.appendChild(child);
              }
            } else if (streamAt > 0) {
              const sibling = (_a = parent.children[streamAt]) != null ? _a : null;
              parent.insertBefore(child, sibling);
            }
          },
          onBeforeNodeAdded: (el) => {
            var _a;
            if (!(el instanceof Element)) {
              return el;
            }
            if (((_a = this.getStreamInsert(el)) == null ? void 0 : _a.updateOnly) && !this.streamComponentRestore[el.id]) {
              return false;
            }
            dom_default.maintainPrivateHooks(el, el, phxViewportTop, phxViewportBottom);
            let morphedEl = el;
            if (this.streamComponentRestore[el.id]) {
              morphedEl = this.streamComponentRestore[el.id];
              delete this.streamComponentRestore[el.id];
              morph(morphedEl, el, true);
            }
            return morphedEl;
          },
          onNodeAdded: (el) => {
            if (!(el instanceof Element)) {
              added.push(el);
              return;
            }
            this.maybeReOrderStream(el, true);
            if (dom_default.isPortalTemplate(el)) {
              portalCallbacks.push(() => this.teleport(el, morph));
            }
            if (el instanceof HTMLImageElement && el.srcset) {
              el.srcset = el.srcset;
            } else if (el instanceof HTMLVideoElement && el.autoplay) {
              el.play();
            }
            if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
              externalFormTriggered = el;
            }
            if (dom_default.isPhxChild(el) && view.ownsElement(el) || dom_default.isPhxSticky(el) && view.ownsElement(el.parentNode)) {
              this.trackAfterPhxChildAdded(el);
            }
            if (el.nodeName === "SCRIPT" && el.hasAttribute(PHX_RUNTIME_HOOK)) {
              el = this.handleRuntimeHook(el, source);
            }
            added.push(el);
          },
          onNodeDiscarded: (el) => this.onNodeDiscarded(el),
          onBeforeNodeDiscarded: (el) => {
            var _a;
            if (!(el instanceof Element)) {
              return true;
            }
            if (el.getAttribute(PHX_PRUNE) !== null) {
              return true;
            }
            if (el.parentElement !== null && el.id && dom_default.isPhxUpdate(el.parentElement, phxUpdate, [
              PHX_STREAM,
              "append",
              "prepend"
            ])) {
              return false;
            }
            if (el.getAttribute(PHX_TELEPORTED_REF)) {
              return false;
            }
            if (this.maybePendingRemove(el)) {
              return false;
            }
            if (this.skipCIDSibling(el)) {
              return false;
            }
            if (dom_default.isPortalTemplate(el)) {
              const teleportedEl = document.getElementById(
                ((_a = el.content.firstElementChild) == null ? void 0 : _a.id) || ""
              );
              if (teleportedEl) {
                teleportedEl.remove();
                morphCallbacks.onNodeDiscarded(teleportedEl);
                this.view.dropPortalElementId(teleportedEl.id);
              }
            }
            return true;
          },
          onElUpdated: (el) => {
            if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
              externalFormTriggered = el;
            }
            updates.push(el);
            this.maybeReOrderStream(el, false);
          },
          onBeforeElUpdated: (fromEl, toEl) => {
            dom_default.syncPendingAttrs(fromEl, toEl);
            dom_default.maintainPrivateHooks(
              fromEl,
              toEl,
              phxViewportTop,
              phxViewportBottom
            );
            dom_default.cleanChildNodes(toEl, phxUpdate, reportError);
            const isFocusedFormEl = focused && fromEl.isSameNode(focused) && dom_default.isEditableInput(fromEl);
            const focusedSelectChanged = isFocusedFormEl && this.isChangedSelect(fromEl, toEl);
            if (this.skipCIDSibling(toEl)) {
              this.maybeCloneLockedElement(fromEl, isFocusedFormEl);
              this.copyNestedPrivateLock(fromEl, toEl);
              this.maybeReOrderStream(fromEl);
              return false;
            }
            if (dom_default.isPhxSticky(fromEl)) {
              [PHX_SESSION, PHX_STATIC, PHX_ROOT_ID].map((attr) => [
                attr,
                fromEl.getAttribute(attr),
                toEl.getAttribute(attr)
              ]).forEach(([attr, fromVal, toVal]) => {
                if (toVal && fromVal !== toVal) {
                  fromEl.setAttribute(attr, toVal);
                }
              });
              return false;
            }
            if (dom_default.isIgnored(fromEl, phxUpdate) || fromEl.form && fromEl.form.isSameNode(externalFormTriggered)) {
              this.trackBeforeUpdated(fromEl, toEl);
              dom_default.mergeAttrs(fromEl, toEl, {
                isIgnored: dom_default.isIgnored(fromEl, phxUpdate)
              });
              updates.push(fromEl);
              dom_default.applyStickyOperations(fromEl);
              return false;
            }
            if (fromEl.type === "number" && fromEl.validity && fromEl.validity.badInput) {
              return false;
            }
            fromEl = this.maybeCloneLockedElement(fromEl, isFocusedFormEl);
            if (dom_default.isPhxChild(toEl)) {
              const prevSession = fromEl.getAttribute(PHX_SESSION);
              dom_default.mergeAttrs(fromEl, toEl, { exclude: [PHX_STATIC] });
              if (prevSession !== "") {
                fromEl.setAttribute(PHX_SESSION, prevSession);
              }
              fromEl.setAttribute(PHX_ROOT_ID, this.rootID);
              dom_default.applyStickyOperations(fromEl);
              return false;
            }
            this.copyNestedPrivateLock(fromEl, toEl);
            dom_default.copyPrivates(toEl, fromEl);
            if (dom_default.isPortalTemplate(toEl)) {
              portalCallbacks.push(() => this.teleport(toEl, morph));
              fromEl.content.replaceChildren(toEl.content.cloneNode(true));
              return false;
            }
            if (isFocusedFormEl && fromEl.type !== "hidden" && !focusedSelectChanged && !toEl.hasAttribute(phxPatchFocused)) {
              this.trackBeforeUpdated(fromEl, toEl);
              dom_default.mergeFocusedInput(fromEl, toEl);
              dom_default.syncAttrsToProps(fromEl);
              updates.push(fromEl);
              dom_default.applyStickyOperations(fromEl);
              return false;
            } else {
              if (focusedSelectChanged) {
                fromEl.blur();
              }
              if (dom_default.isPhxUpdate(toEl, phxUpdate, ["append", "prepend"])) {
                appendPrependUpdates.push(
                  new DOMPostMorphRestorer(
                    fromEl,
                    toEl,
                    toEl.getAttribute(phxUpdate)
                  )
                );
              }
              dom_default.syncAttrsToProps(toEl);
              dom_default.applyStickyOperations(toEl);
              this.trackBeforeUpdated(fromEl, toEl);
              return fromEl;
            }
          }
        };
        index_default(targetContainer2, source, morphCallbacks);
      };
      this.trackBeforeUpdated(container, container);
      liveSocket2.time("morphdom", () => {
        this.streams.forEach(([ref, inserts, deleteIds, reset]) => {
          inserts.forEach(([key, streamAt, limit, updateOnly]) => {
            this.streamInserts[key] = { ref, streamAt, limit, reset, updateOnly };
          });
          if (reset !== void 0) {
            dom_default.all(document, `[${PHX_STREAM_REF}="${ref}"]`, (child) => {
              this.removeStreamChildElement(child);
            });
          }
          deleteIds.forEach((id) => {
            const child = document.getElementById(id);
            if (child) {
              this.removeStreamChildElement(child);
            }
          });
        });
        if (isJoinPatch) {
          dom_default.all(this.container, `[${phxUpdate}=${PHX_STREAM}]`).filter((el) => this.view.ownsElement(el)).forEach((el) => {
            Array.from(el.children).forEach((child) => {
              this.removeStreamChildElement(child, true);
            });
          });
        }
        morph(targetContainer, html);
        let teleportCount = 0;
        while (portalCallbacks.length > 0 && teleportCount < 5) {
          const copy = portalCallbacks.slice();
          portalCallbacks = [];
          copy.forEach((callback) => callback());
          teleportCount++;
        }
        this.view.portalElementIds.forEach((id) => {
          const el = document.getElementById(id);
          if (el) {
            const srcId = el.getAttribute(PHX_TELEPORTED_SRC);
            if (srcId) {
              const source = document.getElementById(srcId);
              if (!source) {
                el.remove();
                this.onNodeDiscarded(el);
                this.view.dropPortalElementId(id);
              }
            }
          }
        });
      });
      if (liveSocket2.isDebugEnabled()) {
        detectDuplicateIds(reportError);
        detectInvalidStreamInserts(this.streamInserts, reportError);
        Array.from(document.querySelectorAll("input[name=id]")).forEach(
          (node) => {
            if (node instanceof HTMLInputElement && node.form) {
              reportError(
                "dom.form-input-name-id",
                'Detected an input with name="id" inside a form! This will cause problems when patching the DOM.\n',
                { el: node },
                { attribution: "app" }
              );
            }
          }
        );
      }
      if (appendPrependUpdates.length > 0) {
        liveSocket2.time("post-morph append/prepend restoration", () => {
          appendPrependUpdates.forEach((update) => update.perform());
        });
      }
      liveSocket2.silenceEvents(
        () => dom_default.restoreFocus(focused, selectionStart, selectionEnd)
      );
      dom_default.dispatchEvent(document, "phx:update");
      added.forEach((el) => this.trackAfterAdded(el));
      updates.forEach((el) => this.trackAfterUpdated(el));
      this.transitionPendingRemoves();
      if (externalFormTriggered) {
        liveSocket2.unload();
        const submitter = dom_default.private(externalFormTriggered, "submitter");
        if (submitter && submitter.name && targetContainer.contains(submitter)) {
          const input = document.createElement("input");
          input.type = "hidden";
          const formId = submitter.getAttribute("form");
          if (formId) {
            input.setAttribute("form", formId);
          }
          input.name = submitter.name;
          input.value = submitter.value;
          submitter.parentElement.insertBefore(input, submitter);
        }
        Object.getPrototypeOf(externalFormTriggered).submit.call(
          externalFormTriggered
        );
      }
      return true;
    }
    trackBeforeUpdated(fromEl, toEl) {
      this.beforeUpdatedCallbacks.forEach((cb) => cb(fromEl, toEl));
    }
    trackAfterAdded(el) {
      this.afterAddedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterUpdated(el) {
      this.afterUpdatedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterPhxChildAdded(el) {
      this.afterPhxChildAddedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterDiscarded(el) {
      this.afterDiscardedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterTransitionsDiscarded(els) {
      this.afterTransitionsDiscardedCallbacks.forEach((cb) => cb(els));
    }
    onNodeDiscarded(el) {
      if (dom_default.isPhxChild(el) || dom_default.isPhxSticky(el)) {
        this.liveSocket.destroyViewByEl(el);
      }
      this.trackAfterDiscarded(el);
    }
    maybePendingRemove(node) {
      if (node.getAttribute && node.getAttribute(this.phxRemove) !== null) {
        this.pendingRemoves.push(node);
        return true;
      } else {
        return false;
      }
    }
    removeStreamChildElement(child, force = false) {
      if (!force && !this.view.ownsElement(child)) {
        return;
      }
      if (this.streamInserts[child.id]) {
        this.streamComponentRestore[child.id] = child;
        child.remove();
      } else {
        if (!this.maybePendingRemove(child)) {
          child.remove();
          this.onNodeDiscarded(child);
        }
      }
    }
    getStreamInsert(el) {
      const insert = el.id ? this.streamInserts[el.id] : {};
      return insert || {};
    }
    setStreamRef(el, ref) {
      dom_default.putSticky(
        el,
        PHX_STREAM_REF,
        (el2) => el2.setAttribute(PHX_STREAM_REF, ref)
      );
    }
    maybeReOrderStream(el, isNew = false) {
      const { ref, streamAt, reset } = this.getStreamInsert(el);
      if (streamAt === void 0) {
        return;
      }
      this.setStreamRef(el, ref);
      if (!reset && !isNew) {
        return;
      }
      if (!el.parentElement) {
        return;
      }
      if (streamAt === 0) {
        this.moveOrInsertBefore(
          el.parentElement,
          el,
          el.parentElement.firstElementChild
        );
      } else if (streamAt > 0) {
        const children = Array.from(el.parentElement.children);
        const oldIndex = children.indexOf(el);
        if (streamAt >= children.length - 1) {
          this.moveOrInsertBefore(el.parentElement, el, null);
        } else {
          const sibling = children[streamAt];
          if (oldIndex > streamAt) {
            this.moveOrInsertBefore(el.parentElement, el, sibling);
          } else {
            this.moveOrInsertBefore(
              el.parentElement,
              el,
              sibling.nextElementSibling
            );
          }
        }
      }
      this.maybeLimitStream(el);
    }
    // Reorder a child within its parent. When supported, use the atomic
    // moveBefore (https://developer.mozilla.org/en-US/docs/Web/API/Node/moveBefore)
    // so connected custom elements (and other state-bearing nodes like iframes)
    // are not disconnected and reconnected by the move. Falls back to
    // insertBefore otherwise. Passing `ref === null` moves to the end.
    // See also https://github.com/phoenixframework/phoenix_live_view/issues/4212.
    moveOrInsertBefore(parent, child, ref) {
      if (typeof parent.moveBefore === "function") {
        try {
          parent.moveBefore(child, ref);
          return;
        } catch (e2) {
        }
      }
      parent.insertBefore(child, ref);
    }
    maybeLimitStream(el) {
      const { limit } = this.getStreamInsert(el);
      if (limit !== null) {
        const children = Array.from(el.parentElement.children);
        if (limit < 0 && children.length > limit * -1) {
          children.slice(0, children.length + limit).forEach((child) => this.removeStreamChildElement(child));
        } else if (limit >= 0 && children.length > limit) {
          children.slice(limit).forEach((child) => this.removeStreamChildElement(child));
        }
      }
    }
    transitionPendingRemoves() {
      const { pendingRemoves, liveSocket: liveSocket2 } = this;
      if (pendingRemoves.length > 0) {
        liveSocket2.transitionRemoves(pendingRemoves, this.view, () => {
          pendingRemoves.forEach((el) => {
            const child = dom_default.firstPhxChild(el);
            if (child) {
              liveSocket2.destroyViewByEl(child);
            }
            el.remove();
          });
          this.trackAfterTransitionsDiscarded(pendingRemoves);
        });
      }
    }
    isChangedSelect(fromEl, toEl) {
      if (!(fromEl instanceof HTMLSelectElement) || fromEl.multiple) {
        return false;
      }
      if (fromEl.options.length !== toEl.options.length) {
        return true;
      }
      toEl.value = fromEl.value;
      return !fromEl.isEqualNode(toEl);
    }
    skipCIDSibling(el) {
      return el.nodeType === Node.ELEMENT_NODE && el.hasAttribute(PHX_SKIP);
    }
    maybeCloneLockedElement(fromEl, isFocusedFormEl) {
      if (!fromEl.hasAttribute(PHX_REF_SRC))
        return fromEl;
      const ref = new ElementRef(fromEl);
      if (!fromEl.hasAttribute(PHX_REF_LOCK) || this.undoRef !== null && ref.isLockUndoneBy(this.undoRef)) {
        return fromEl;
      }
      dom_default.applyStickyOperations(fromEl);
      const clone2 = fromEl.hasAttribute(PHX_REF_LOCK) ? dom_default.private(fromEl, PHX_REF_LOCK) || fromEl.cloneNode(true) : null;
      if (!clone2)
        return fromEl;
      dom_default.putPrivate(fromEl, PHX_REF_LOCK, clone2);
      return isFocusedFormEl ? fromEl : clone2;
    }
    copyNestedPrivateLock(fromEl, toEl) {
      if (this.undoRef === null || !dom_default.private(toEl, PHX_REF_LOCK))
        return;
      dom_default.putPrivate(fromEl, PHX_REF_LOCK, dom_default.private(toEl, PHX_REF_LOCK));
    }
    teleport(el, morph) {
      const targetSelector = el.getAttribute(PHX_PORTAL);
      const portalContainer = document.querySelector(targetSelector);
      if (!portalContainer) {
        throw new Error(
          "portal target with selector " + targetSelector + " not found"
        );
      }
      const toTeleport = el.content.firstElementChild;
      if (this.skipCIDSibling(toTeleport)) {
        return;
      }
      if (!(toTeleport == null ? void 0 : toTeleport.id)) {
        throw new Error(
          "phx-portal template must have a single root element with ID!"
        );
      }
      const existing = document.getElementById(toTeleport.id);
      let portalTarget;
      if (existing) {
        if (!portalContainer.contains(existing)) {
          portalContainer.appendChild(existing);
        }
        portalTarget = existing;
      } else {
        portalTarget = document.createElementNS(
          toTeleport.namespaceURI,
          toTeleport.localName
        );
        portalContainer.appendChild(portalTarget);
      }
      toTeleport.setAttribute(PHX_TELEPORTED_REF, this.view.id);
      toTeleport.setAttribute(PHX_TELEPORTED_SRC, el.id);
      morph(portalTarget, toTeleport.cloneNode(true), true);
      toTeleport.removeAttribute(PHX_TELEPORTED_REF);
      toTeleport.removeAttribute(PHX_TELEPORTED_SRC);
      this.view.pushPortalElementId(toTeleport.id);
    }
    handleRuntimeHook(el, source) {
      var _a, _b;
      const name = el.getAttribute(PHX_RUNTIME_HOOK);
      let nonce = el.hasAttribute("nonce") ? el.getAttribute("nonce") : null;
      if (el.hasAttribute("nonce")) {
        const template = document.createElement("template");
        template.innerHTML = source;
        nonce = (_b = (_a = template.content.querySelector(`script[${PHX_RUNTIME_HOOK}="${CSS.escape(name)}"]`)) == null ? void 0 : _a.getAttribute("nonce")) != null ? _b : null;
      }
      const script = document.createElement("script");
      script.textContent = el.textContent;
      dom_default.mergeAttrs(script, el, { isIgnored: false });
      if (nonce) {
        script.nonce = nonce;
      }
      el.replaceWith(script);
      return script;
    }
  };
  var VOID_TAGS = /* @__PURE__ */ new Set([
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr"
  ]);
  var quoteChars = /* @__PURE__ */ new Set(["'", '"']);
  var modifyRoot = (html, attrs, clearInnerHTML) => {
    let i;
    let insideComment;
    let beforeTag, afterTag, tag, tagNameEndsAt, id, newHTML;
    const lookahead = html.match(/^(\s*(?:<!--.*?-->\s*)*)<([^\s\/>]+)/);
    if (lookahead === null) {
      throw new Error(`malformed html ${html}`);
    }
    i = lookahead[0].length;
    beforeTag = lookahead[1];
    tag = lookahead[2];
    tagNameEndsAt = i;
    for (i; i < html.length; i++) {
      if (html.charAt(i) === ">") {
        break;
      }
      if (html.charAt(i) === "=") {
        const isId = html.slice(i - 3, i) === " id";
        i++;
        const char = html.charAt(i);
        if (quoteChars.has(char)) {
          const attrStartsAt = i;
          i++;
          for (i; i < html.length; i++) {
            if (html.charAt(i) === char) {
              break;
            }
          }
          if (isId) {
            id = html.slice(attrStartsAt + 1, i);
            break;
          }
        }
      }
    }
    let closeAt = html.length - 1;
    insideComment = false;
    while (closeAt >= beforeTag.length + tag.length) {
      const char = html.charAt(closeAt);
      if (insideComment) {
        if (char === "-" && html.slice(closeAt - 3, closeAt) === "<!-") {
          insideComment = false;
          closeAt -= 4;
        } else {
          closeAt -= 1;
        }
      } else if (char === ">" && html.slice(closeAt - 2, closeAt) === "--") {
        insideComment = true;
        closeAt -= 3;
      } else if (char === ">") {
        break;
      } else {
        closeAt -= 1;
      }
    }
    afterTag = html.slice(closeAt + 1, html.length);
    const attrsStr = Object.keys(attrs).map((attr) => attrs[attr] === true ? attr : `${attr}="${attrs[attr]}"`).join(" ");
    if (clearInnerHTML) {
      const idAttrStr = id ? ` id="${id}"` : "";
      if (VOID_TAGS.has(tag)) {
        newHTML = `<${tag}${idAttrStr}${attrsStr === "" ? "" : " "}${attrsStr}/>`;
      } else {
        newHTML = `<${tag}${idAttrStr}${attrsStr === "" ? "" : " "}${attrsStr}></${tag}>`;
      }
    } else {
      const rest = html.slice(tagNameEndsAt, closeAt + 1);
      newHTML = `<${tag}${attrsStr === "" ? "" : " "}${attrsStr}${rest}`;
    }
    return [newHTML, beforeTag, afterTag];
  };
  var RenderingBuffer = class {
    constructor(_preMerge, _cid) {
      this.html = "";
      this.pending = [];
    }
    /**
     * Characters written so far, counting what an open root was split off from.
     * A buffer that records positions brackets spans with this.
     *
     * Summed on read rather than tracked on write: only a buffer that records
     * positions ever asks, and tracking it charged every render that never does.
     * Roots nest shallowly, so the walk is short.
     */
    get length() {
      let total = this.html.length;
      for (let i = 0; i < this.pending.length; i++) {
        total += this.pending[i].length;
      }
      return total;
    }
    write(str) {
      this.html += str;
    }
    toString() {
      return this.html;
    }
    /**
     * Brackets a root element: everything written in between is a single
     * element, `attrs` are added to its start tag, and `clearInnerHTML`
     * additionally discards its contents (LiveView skips re-rendering a root
     * that did not change and reuses what is already in the DOM).
     *
     * The default isolates the element so it can rewrite it without touching
     * what came before. A buffer that records positions overrides both, keeping
     * it continuous and applying its edits at the end instead; `length` stays
     * continuous across the pair either way.
     */
    beginRoot() {
      this.pending.push(this.html);
      this.html = "";
    }
    endRoot(attrs, clearInnerHTML) {
      const [root, before, after] = modifyRoot(this.html, attrs, clearInnerHTML);
      this.html = this.pending.pop() + before + root + after;
    }
    /**
     * Brackets the dynamic at `statics[index]` of `node`. Called around every
     * dynamic of every render, so the default has to be cheap; see
     * {@link ReportingBuffer} for what a buffer can do with it.
     */
    enter(_node, _index, _statics) {
    }
    exit() {
    }
    /**
     * Brackets one entry of a keyed comprehension. Entries hold dynamics without
     * being one themselves, so they are opened separately from `enter`.
     */
    beginKeyedEntry(_index) {
    }
    endKeyedEntry() {
    }
  };
  var ALL_CHANGED = Symbol("all changed");
  var ReportingBuffer = class extends RenderingBuffer {
    constructor(preMerge, cid) {
      super(preMerge, cid);
      this.frames = [];
      this.cursors = [];
      this.diff = this.cursorFor(preMerge, cid);
    }
    // Cloning is not optional: the merge adopts diff subtrees into the rendered
    // tree and then mutates them. The copy is shared by every buffer of the
    // render that follows, so nothing here may consume it.
    static preMerge(diff) {
      return deepClone(diff);
    }
    cursorFor(preMerge, cid) {
      if (!preMerge) {
        return void 0;
      } else if (cid === null) {
        return preMerge;
      } else {
        return preMerge[COMPONENTS] && preMerge[COMPONENTS][cid];
      }
    }
    /**
     * Called around every dynamic in the tree. A change is reported at every
     * level, so a dynamic containing a changed one is itself reported as
     * changed; a buffer that wants to attribute a change to the innermost thing
     * that changed applies that policy itself, walking `frames`.
     */
    onEnter(_frame) {
    }
    onExit(_frame) {
    }
    /** Where in the diff the renderer currently is. */
    currentDiff() {
      return this.cursors.length > 0 ? this.cursors[this.cursors.length - 1] : this.diff;
    }
    enter(node, index, statics) {
      const diff = this.diffFor(this.currentDiff(), index);
      const frame = {
        node,
        index,
        statics,
        changed: diff !== void 0
      };
      this.cursors.push(diff);
      this.frames.push(frame);
      this.onEnter(frame);
    }
    exit() {
      this.cursors.pop();
      this.onExit(this.frames.pop());
    }
    beginKeyedEntry(index) {
      this.cursors.push(this.keyedEntry(this.currentDiff(), index));
    }
    endKeyedEntry() {
      this.cursors.pop();
    }
    keyedEntry(diffNode, index) {
      const keyed = this.diffFor(diffNode, KEYED);
      if (keyed === ALL_CHANGED || keyed === void 0) {
        return keyed;
      }
      const entry = keyed[index];
      if (Array.isArray(entry)) {
        return entry[1];
      } else if (typeof entry === "number") {
        return void 0;
      } else {
        return entry;
      }
    }
    diffFor(diffNode, key) {
      if (diffNode === void 0 || diffNode === null) {
        return void 0;
      } else if (diffNode === ALL_CHANGED || diffNode[STATIC] !== void 0) {
        return ALL_CHANGED;
      } else {
        return diffNode[key];
      }
    }
  };
  var Rendered = class {
    static extract(diff) {
      const { [REPLY]: reply, [EVENTS]: events, [TITLE]: title } = diff;
      delete diff[REPLY];
      delete diff[EVENTS];
      delete diff[TITLE];
      return { diff, title, reply: reply || null, events: events || [] };
    }
    // The buffer class is read afresh on every merge and every render rather
    // than held, so one installed after this tree mounted still takes effect —
    // for the parts of the page the next patch renders, and no sooner.
    constructor(viewId, rendered, bufferClass = () => RenderingBuffer) {
      this.viewId = viewId;
      this.rendered = {};
      this.magicId = 0;
      this.bufferClass = bufferClass;
      this.initialMerge = true;
      this.mergeDiff(rendered);
      this.initialMerge = false;
    }
    parentViewId() {
      return this.viewId;
    }
    toString(onlyCids) {
      const { buffer: str, streams } = this.recursiveToString(
        this.rendered,
        this.rendered[COMPONENTS],
        onlyCids,
        true,
        {},
        null
      );
      return { buffer: str, streams };
    }
    // cid identifies the subtree being rendered to the buffer: null for the root
    // tree, a component id otherwise.
    recursiveToString(rendered, components = rendered[COMPONENTS], onlyCids, changeTracking, rootAttrs, cid) {
      onlyCids = onlyCids ? new Set(onlyCids) : null;
      const bufferClass = this.bufferClass();
      const [mergedBy, preMerge] = this.bufferPreMerge;
      const buffer = new bufferClass(
        mergedBy === bufferClass ? preMerge : void 0,
        cid
      );
      const output = {
        buffer,
        components,
        onlyCids,
        streams: /* @__PURE__ */ new Set()
      };
      this.toOutputBuffer(rendered, null, output, changeTracking, rootAttrs);
      return { buffer: buffer.toString(), streams: output.streams };
    }
    componentCIDs(diff) {
      return Object.keys(diff[COMPONENTS] || {}).map((i) => parseInt(i));
    }
    isComponentOnlyDiff(diff) {
      if (!diff[COMPONENTS]) {
        return false;
      }
      return Object.keys(diff).length === 1;
    }
    getComponent(diff, cid) {
      return diff[COMPONENTS][cid];
    }
    resetRender(cid) {
      if (this.rendered[COMPONENTS][cid]) {
        this.rendered[COMPONENTS][cid].reset = true;
      }
    }
    mergeDiff(diff) {
      const bufferClass = this.bufferClass();
      this.bufferPreMerge = [
        bufferClass,
        !this.initialMerge && bufferClass.preMerge ? bufferClass.preMerge(diff) : void 0
      ];
      const newc = diff[COMPONENTS];
      const cache = {};
      delete diff[COMPONENTS];
      this.rendered = this.mutableMerge(this.rendered, diff);
      this.rendered[COMPONENTS] = this.rendered[COMPONENTS] || {};
      if (newc) {
        const oldc = this.rendered[COMPONENTS];
        for (const cid in newc) {
          newc[cid] = this.cachedFindComponent(cid, newc[cid], oldc, newc, cache);
        }
        for (const cid in newc) {
          oldc[cid] = newc[cid];
        }
        diff[COMPONENTS] = newc;
      }
    }
    cachedFindComponent(cid, cdiff, oldc, newc, cache) {
      if (cache[cid]) {
        return cache[cid];
      } else {
        let ndiff, stat, scid = cdiff[STATIC];
        if (isCid(scid)) {
          let tdiff;
          if (scid > 0) {
            tdiff = this.cachedFindComponent(scid, newc[scid], oldc, newc, cache);
          } else {
            tdiff = oldc[-scid];
          }
          stat = tdiff[STATIC];
          ndiff = this.cloneMerge(tdiff, cdiff, true);
          ndiff[STATIC] = stat;
        } else {
          ndiff = cdiff[STATIC] !== void 0 || oldc[cid] === void 0 ? cdiff : this.cloneMerge(oldc[cid], cdiff, false);
        }
        cache[cid] = ndiff;
        return ndiff;
      }
    }
    mutableMerge(target, source) {
      if (source[STATIC] !== void 0) {
        return source;
      } else {
        this.doMutableMerge(target, source);
        return target;
      }
    }
    doMutableMerge(target, source) {
      if (source[KEYED]) {
        this.mergeKeyed(target, source);
      } else {
        for (const key in source) {
          const val = source[key];
          const targetVal = target[key];
          const isObjVal = isObject(val);
          if (isObjVal && val[STATIC] === void 0 && isObject(targetVal)) {
            this.doMutableMerge(targetVal, val);
          } else {
            target[key] = val;
          }
        }
      }
      if (target[ROOT]) {
        target.newRender = true;
      }
    }
    clone(diff) {
      return deepClone(diff);
    }
    // keyed comprehensions
    mergeKeyed(target, source) {
      const clonedTarget = source[KEYED][KEYED_MOVED] && this.clone(target);
      Object.entries(source[KEYED]).forEach(([i, entry]) => {
        if (i === KEYED_COUNT || i === KEYED_MOVED) {
          return;
        }
        if (Array.isArray(entry)) {
          const [old_idx, diff] = entry;
          target[KEYED][i] = clonedTarget[KEYED][old_idx];
          this.doMutableMerge(target[KEYED][i], diff);
        } else if (typeof entry === "number") {
          const old_idx = entry;
          target[KEYED][i] = clonedTarget[KEYED][old_idx];
        } else if (typeof entry === "object") {
          if (!target[KEYED][i]) {
            target[KEYED][i] = {};
          }
          this.doMutableMerge(target[KEYED][i], entry);
        }
      });
      if (source[KEYED][KEYED_COUNT] < target[KEYED][KEYED_COUNT]) {
        for (let i = source[KEYED][KEYED_COUNT]; i < target[KEYED][KEYED_COUNT]; i++) {
          delete target[KEYED][i];
        }
      }
      target[KEYED][KEYED_COUNT] = source[KEYED][KEYED_COUNT];
      if (source[STREAM]) {
        target[STREAM] = source[STREAM];
      }
      if (source[TEMPLATES]) {
        target[TEMPLATES] = source[TEMPLATES];
      }
    }
    // Merges cid trees together, copying statics from source tree.
    //
    // The `pruneMagicId` is passed to control pruning the magicId of the
    // target. We must always prune the magicId when we are sharing statics
    // from another component. If not pruning, we replicate the logic from
    // mutableMerge, where we set newRender to true if there is a root
    // (effectively forcing the new version to be rendered instead of skipped)
    //
    cloneMerge(target, source, pruneMagicId) {
      let merged;
      if (source[KEYED]) {
        merged = this.clone(target);
        this.mergeKeyed(merged, source);
        if (pruneMagicId) {
          this.pruneInternalIds(merged);
        }
      } else {
        merged = __spreadValues(__spreadValues({}, target), source);
        for (const key in merged) {
          const val = source[key];
          const targetVal = target[key];
          if (isObject(val) && val[STATIC] === void 0 && isObject(targetVal)) {
            merged[key] = this.cloneMerge(targetVal, val, pruneMagicId);
          } else if (val === void 0 && isObject(targetVal)) {
            merged[key] = this.cloneMerge(targetVal, {}, pruneMagicId);
          }
        }
      }
      if (pruneMagicId) {
        this.deleteInternalIds(merged);
      } else if (target[ROOT]) {
        merged.newRender = true;
      }
      return merged;
    }
    // A component sharing statics with another cid is cloned from that cid's
    // tree, which would otherwise carry that cid's magic IDs along. They identify
    // the node they came from, so a duplicate would be wrong for as long as the
    // clone lives.
    pruneInternalIds(rendered) {
      for (const key in rendered) {
        if (isObject(rendered[key])) {
          this.pruneInternalIds(rendered[key]);
        }
      }
      this.deleteInternalIds(rendered);
    }
    deleteInternalIds(rendered) {
      delete rendered.magicId;
      delete rendered.newRender;
    }
    componentToString(cid) {
      const { buffer: str, streams } = this.recursiveCIDToString(
        this.rendered[COMPONENTS],
        cid,
        null
      );
      const [strippedHTML, _before, _after] = modifyRoot(str, {});
      return { buffer: strippedHTML, streams };
    }
    pruneCIDs(cids) {
      cids.forEach((cid) => delete this.rendered[COMPONENTS][cid]);
    }
    // private
    get() {
      return this.rendered;
    }
    isNewFingerprint(diff = {}) {
      return !!diff[STATIC];
    }
    templateStatic(part, templates) {
      if (typeof part === "number") {
        return templates[part];
      } else {
        return part;
      }
    }
    nextMagicID() {
      this.magicId++;
      return `m${this.magicId}-${this.parentViewId()}`;
    }
    // Converts rendered tree to output buffer.
    //
    // changeTracking controls if we can apply the PHX_SKIP optimization.
    toOutputBuffer(rendered, templates, output, changeTracking, rootAttrs = {}) {
      if (rendered[KEYED]) {
        return this.comprehensionToBuffer(
          rendered,
          templates,
          output,
          changeTracking
        );
      }
      if (rendered[TEMPLATES]) {
        templates = rendered[TEMPLATES];
        delete rendered[TEMPLATES];
      }
      let { [STATIC]: statics } = rendered;
      statics = this.templateStatic(statics, templates);
      rendered[STATIC] = statics;
      const isRoot = rendered[ROOT];
      if (isRoot) {
        output.buffer.beginRoot();
      }
      if (changeTracking && isRoot && !rendered.magicId) {
        rendered.newRender = true;
        rendered.magicId = this.nextMagicID();
      }
      this.dynamicsToBuffer(rendered, statics, templates, output, changeTracking);
      if (isRoot) {
        let skip = false;
        let attrs;
        if (changeTracking || rendered.magicId) {
          skip = changeTracking && !rendered.newRender;
          attrs = __spreadValues({ [PHX_MAGIC_ID]: rendered.magicId }, rootAttrs);
        } else {
          attrs = rootAttrs;
        }
        if (skip) {
          attrs[PHX_SKIP] = true;
        }
        output.buffer.endRoot(attrs, skip);
        rendered.newRender = false;
      }
    }
    // Emits `statics` interleaved with the dynamics held on `node`, which is
    // either a rendered struct or a single entry of a keyed comprehension.
    //
    // Every dynamic is opened and closed on the buffer, whether or not the buffer
    // does anything with it. Skipping that for buffers that do not care was worth
    // ~4-6% of render on component-heavy trees and nothing on any other shape,
    // which is under 1% of a patch once the DOM work around it is counted — not
    // worth a capability flag a buffer can forget to set.
    dynamicsToBuffer(node, statics, templates, output, changeTracking) {
      const buffer = output.buffer;
      for (let i = 0; i < statics.length - 1; i++) {
        buffer.write(statics[i]);
        buffer.enter(node, i, statics);
        this.dynamicToBuffer(node[i], templates, output, changeTracking);
        buffer.exit();
      }
      buffer.write(statics[statics.length - 1]);
    }
    comprehensionToBuffer(rendered, templates, output, changeTracking) {
      const keyedTemplates = templates || rendered[TEMPLATES];
      const statics = this.templateStatic(rendered[STATIC], templates);
      rendered[STATIC] = statics;
      delete rendered[TEMPLATES];
      for (let i = 0; i < rendered[KEYED][KEYED_COUNT]; i++) {
        output.buffer.beginKeyedEntry(i);
        this.dynamicsToBuffer(
          rendered[KEYED][i],
          statics,
          keyedTemplates,
          output,
          changeTracking
        );
        output.buffer.endKeyedEntry();
      }
      if (rendered[STREAM]) {
        const stream = rendered[STREAM];
        const [_ref, _inserts, deleteIds, reset] = stream;
        if (rendered[KEYED][KEYED_COUNT] > 0 || deleteIds.length > 0 || reset) {
          delete rendered[STREAM];
          rendered[KEYED] = {
            [KEYED_COUNT]: 0
          };
          output.streams.add(stream);
        }
      }
    }
    dynamicToBuffer(rendered, templates, output, changeTracking) {
      if (typeof rendered === "number") {
        const { buffer: str, streams } = this.recursiveCIDToString(
          output.components,
          rendered,
          output.onlyCids
        );
        output.buffer.write(str);
        for (const s of streams) {
          output.streams.add(s);
        }
      } else if (isObject(rendered)) {
        this.toOutputBuffer(rendered, templates, output, changeTracking, {});
      } else {
        output.buffer.write(rendered);
      }
    }
    recursiveCIDToString(components, cid, onlyCids) {
      if (components[cid]) {
        const component = components[cid];
        const attrs = { [PHX_COMPONENT]: cid, [PHX_VIEW_REF]: this.viewId };
        const skip = onlyCids && !onlyCids.has(cid);
        component.newRender = !skip;
        component.magicId = `c${cid}-${this.parentViewId()}`;
        const changeTracking = !component.reset;
        const { buffer: html, streams } = this.recursiveToString(
          component,
          components,
          onlyCids,
          changeTracking,
          attrs,
          cid
        );
        delete component.reset;
        return { buffer: html, streams };
      } else {
        logError(
          "render.missing-component",
          `no component for CID ${cid}`,
          {
            cid,
            components
          },
          { viewId: this.viewId, attribution: "internal" }
        );
        throw new Error(
          "Cannot continue render due to missing component: " + cid
        );
      }
    }
  };
  var focusStack = [];
  var default_transition_time = 200;
  var JS = {
    // private
    exec(e2, eventType, phxEvent, view, sourceEl, defaults) {
      const [defaultKind, defaultArgs] = defaults || [
        null,
        { callback: defaults && defaults.callback }
      ];
      const commands = Array.isArray(phxEvent) ? phxEvent : typeof phxEvent === "string" && phxEvent.startsWith("[") ? JSON.parse(phxEvent) : [[defaultKind, defaultArgs]];
      commands.forEach(([kind, args]) => {
        if (kind === defaultKind) {
          args = __spreadValues(__spreadValues({}, defaultArgs), args);
          args.callback = args.callback || defaultArgs.callback;
        }
        this.filterToEls(view.liveSocket, sourceEl, args).forEach((el) => {
          this[`exec_${kind}`](e2, eventType, phxEvent, view, sourceEl, el, args);
        });
      });
    },
    isVisible(el) {
      return !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);
    },
    // returns true if any part of the element is inside the viewport
    isInViewport(el) {
      const rect = el.getBoundingClientRect();
      const windowHeight = window.innerHeight || document.documentElement.clientHeight;
      const windowWidth = window.innerWidth || document.documentElement.clientWidth;
      return rect.right > 0 && rect.bottom > 0 && rect.left < windowWidth && rect.top < windowHeight;
    },
    // private
    // commands
    exec_exec(e2, eventType, phxEvent, view, sourceEl, el, { attr, to }) {
      const encodedJS = el.getAttribute(attr);
      if (!encodedJS) {
        throw new Error(`expected ${attr} to contain JS command on "${to}"`);
      }
      view.liveSocket.execJS(el, encodedJS, eventType);
    },
    exec_dispatch(e2, eventType, phxEvent, view, sourceEl, el, { event, detail, bubbles, blocking }) {
      detail = detail || {};
      detail.dispatcher = sourceEl;
      if (blocking) {
        const promise = new Promise((resolve, _reject) => {
          detail.done = resolve;
        });
        view.liveSocket.asyncTransition(promise);
      }
      dom_default.dispatchEvent(el, event, { detail, bubbles });
    },
    exec_push(e2, eventType, phxEvent, view, sourceEl, el, args) {
      const {
        event,
        data,
        target,
        page_loading,
        loading,
        value,
        dispatcher,
        callback
      } = args;
      const pushOpts = {
        loading,
        value,
        target,
        page_loading: !!page_loading,
        originalEvent: e2
      };
      const targetSrc = eventType === "change" && dispatcher ? dispatcher : sourceEl;
      const phxTarget = target || targetSrc.getAttribute(view.binding("target")) || targetSrc;
      const handler = (targetView, targetCtx) => {
        if (!targetView.isConnected()) {
          return;
        }
        if (eventType === "change") {
          let { newCid, _target } = args;
          _target = _target || (dom_default.isFormAssociated(sourceEl) ? sourceEl.name : void 0);
          if (_target) {
            pushOpts._target = _target;
          }
          targetView.pushInput(
            sourceEl,
            targetCtx,
            newCid,
            event || phxEvent,
            pushOpts,
            callback
          );
        } else if (eventType === "submit") {
          const { submitter } = args;
          targetView.submitForm(
            sourceEl,
            targetCtx,
            event || phxEvent,
            submitter,
            pushOpts,
            callback
          );
        } else {
          targetView.pushEvent(
            eventType,
            sourceEl,
            targetCtx,
            event || phxEvent,
            data,
            pushOpts,
            callback
          );
        }
      };
      if (args.targetView && args.targetCtx) {
        handler(args.targetView, args.targetCtx);
      } else {
        view.withinTargets(phxTarget, handler);
      }
    },
    exec_navigate(e2, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
      view.liveSocket.historyRedirect(
        e2,
        href,
        replace ? "replace" : "push",
        null,
        sourceEl
      );
    },
    exec_patch(e2, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
      view.liveSocket.pushHistoryPatch(
        e2,
        href,
        replace ? "replace" : "push",
        sourceEl
      );
    },
    exec_focus(e2, eventType, phxEvent, view, sourceEl, el) {
      aria_default.attemptFocus(el);
      window.requestAnimationFrame(() => {
        window.requestAnimationFrame(() => aria_default.attemptFocus(el));
      });
    },
    exec_focus_first(e2, eventType, phxEvent, view, sourceEl, el) {
      aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el);
      window.requestAnimationFrame(() => {
        window.requestAnimationFrame(
          () => aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el)
        );
      });
    },
    exec_push_focus(e2, eventType, phxEvent, view, sourceEl, el) {
      if (view.isDestroyed()) {
        return;
      }
      focusStack.push({ el: el || sourceEl, view });
    },
    exec_pop_focus(_e2, _eventType, _phxEvent, view, _sourceEl, _el) {
      if (view.isDestroyed()) {
        return;
      }
      const focusEntry = focusStack.pop();
      if (focusEntry) {
        const { el } = focusEntry;
        el.focus();
        window.requestAnimationFrame(() => {
          window.requestAnimationFrame(() => el.focus());
        });
      }
    },
    dropFocus(view) {
      let dropped = 0;
      for (let i = focusStack.length - 1; i >= 0; i--) {
        if (focusStack[i].view === view) {
          focusStack.splice(i, 1);
          dropped++;
        }
      }
      return dropped;
    },
    exec_add_class(e2, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.addOrRemoveClasses(el, names, [], transition, time, view, blocking);
    },
    exec_remove_class(e2, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.addOrRemoveClasses(el, [], names, transition, time, view, blocking);
    },
    exec_toggle_class(e2, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.toggleClasses(el, names, transition, time, view, blocking);
    },
    exec_toggle_attr(e2, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val1, val2] }) {
      this.toggleAttr(el, attr, val1, val2);
    },
    exec_ignore_attrs(e2, eventType, phxEvent, view, sourceEl, el, { attrs }) {
      this.ignoreAttrs(el, attrs);
    },
    exec_transition(e2, eventType, phxEvent, view, sourceEl, el, { time, transition, blocking }) {
      this.addOrRemoveClasses(el, [], [], transition, time, view, blocking);
    },
    exec_toggle(e2, eventType, phxEvent, view, sourceEl, el, { display, ins, outs, time, blocking }) {
      this.toggle(eventType, view, el, display, ins, outs, time, blocking);
    },
    exec_show(e2, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
      this.show(eventType, view, el, display, transition, time, blocking);
    },
    exec_hide(e2, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
      this.hide(eventType, view, el, display, transition, time, blocking);
    },
    exec_set_attr(e2, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val] }) {
      this.setOrRemoveAttrs(el, [[attr, val]], []);
    },
    exec_remove_attr(e2, eventType, phxEvent, view, sourceEl, el, { attr }) {
      this.setOrRemoveAttrs(el, [], [attr]);
    },
    ignoreAttrs(el, attrs) {
      dom_default.putPrivate(el, "JS:ignore_attrs", {
        apply: (fromEl, toEl) => {
          let fromAttributes = Array.from(fromEl.attributes);
          let fromAttributeNames = fromAttributes.map((attr) => attr.name);
          Array.from(toEl.attributes).filter((attr) => {
            return !fromAttributeNames.includes(attr.name);
          }).forEach((attr) => {
            if (dom_default.attributeIgnored(attr, attrs)) {
              toEl.removeAttribute(attr.name);
            }
          });
          fromAttributes.forEach((attr) => {
            if (dom_default.attributeIgnored(attr, attrs)) {
              toEl.setAttribute(attr.name, attr.value);
            }
          });
        }
      });
    },
    onBeforeElUpdated(fromEl, toEl) {
      const ignoreAttrs = dom_default.private(fromEl, "JS:ignore_attrs");
      if (ignoreAttrs) {
        ignoreAttrs.apply(fromEl, toEl);
      }
    },
    // utils for commands
    show(eventType, view, el, display, transition, time, blocking) {
      if (!this.isVisible(el)) {
        this.toggle(
          eventType,
          view,
          el,
          display,
          transition,
          null,
          time,
          blocking
        );
      }
    },
    hide(eventType, view, el, display, transition, time, blocking) {
      if (this.isVisible(el)) {
        this.toggle(
          eventType,
          view,
          el,
          display,
          null,
          transition,
          time,
          blocking
        );
      }
    },
    toggle(eventType, view, el, display, ins, outs, time, blocking) {
      time = time == null ? default_transition_time : time;
      const [inClasses, inStartClasses, inEndClasses] = ins || [[], [], []];
      const [outClasses, outStartClasses, outEndClasses] = outs || [[], [], []];
      if (inClasses.length > 0 || outClasses.length > 0) {
        if (this.isVisible(el)) {
          const onStart = () => {
            this.addOrRemoveClasses(
              el,
              outStartClasses,
              inClasses.concat(inStartClasses).concat(inEndClasses)
            );
            window.requestAnimationFrame(() => {
              this.addOrRemoveClasses(el, outClasses, []);
              window.requestAnimationFrame(
                () => this.addOrRemoveClasses(el, outEndClasses, outStartClasses)
              );
            });
          };
          const onEnd = () => {
            this.addOrRemoveClasses(el, [], outClasses.concat(outEndClasses));
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = "none"
            );
            el.dispatchEvent(new Event("phx:hide-end"));
          };
          el.dispatchEvent(new Event("phx:hide-start"));
          if (blocking === false) {
            onStart();
            setTimeout(onEnd, time);
          } else {
            view.transition(time, onStart, onEnd);
          }
        } else {
          if (eventType === "remove") {
            return;
          }
          const onStart = () => {
            this.addOrRemoveClasses(
              el,
              inStartClasses,
              outClasses.concat(outStartClasses).concat(outEndClasses)
            );
            const stickyDisplay = display || this.defaultDisplay(el);
            window.requestAnimationFrame(() => {
              this.addOrRemoveClasses(el, inClasses, []);
              window.requestAnimationFrame(() => {
                dom_default.putSticky(
                  el,
                  "toggle",
                  (currentEl) => currentEl.style.display = stickyDisplay
                );
                this.addOrRemoveClasses(el, inEndClasses, inStartClasses);
              });
            });
          };
          const onEnd = () => {
            this.addOrRemoveClasses(el, [], inClasses.concat(inEndClasses));
            el.dispatchEvent(new Event("phx:show-end"));
          };
          el.dispatchEvent(new Event("phx:show-start"));
          if (blocking === false) {
            onStart();
            setTimeout(onEnd, time);
          } else {
            view.transition(time, onStart, onEnd);
          }
        }
      } else {
        if (this.isVisible(el)) {
          window.requestAnimationFrame(() => {
            el.dispatchEvent(new Event("phx:hide-start"));
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = "none"
            );
            el.dispatchEvent(new Event("phx:hide-end"));
          });
        } else {
          window.requestAnimationFrame(() => {
            el.dispatchEvent(new Event("phx:show-start"));
            const stickyDisplay = display || this.defaultDisplay(el);
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = stickyDisplay
            );
            el.dispatchEvent(new Event("phx:show-end"));
          });
        }
      }
    },
    toggleClasses(el, classes, transition, time, view, blocking) {
      window.requestAnimationFrame(() => {
        const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
        const newAdds = classes.filter(
          (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
        );
        const newRemoves = classes.filter(
          (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
        );
        this.addOrRemoveClasses(
          el,
          newAdds,
          newRemoves,
          transition,
          time,
          view,
          blocking
        );
      });
    },
    toggleAttr(el, attr, val1, val2) {
      if (el.hasAttribute(attr)) {
        if (val2 !== void 0) {
          if (el.getAttribute(attr) === val1) {
            this.setOrRemoveAttrs(el, [[attr, val2]], []);
          } else {
            this.setOrRemoveAttrs(el, [[attr, val1]], []);
          }
        } else {
          this.setOrRemoveAttrs(el, [], [attr]);
        }
      } else {
        this.setOrRemoveAttrs(el, [[attr, val1]], []);
      }
    },
    addOrRemoveClasses(el, adds, removes, transition, time, view, blocking) {
      time = time == null ? default_transition_time : time;
      const [transitionRun, transitionStart, transitionEnd] = transition || [
        [],
        [],
        []
      ];
      if (transitionRun.length > 0) {
        const onStart = () => {
          this.addOrRemoveClasses(
            el,
            transitionStart,
            [].concat(transitionRun).concat(transitionEnd)
          );
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, transitionRun, []);
            window.requestAnimationFrame(
              () => this.addOrRemoveClasses(el, transitionEnd, transitionStart)
            );
          });
        };
        const onDone = () => this.addOrRemoveClasses(
          el,
          adds.concat(transitionEnd),
          removes.concat(transitionRun).concat(transitionStart)
        );
        if (blocking === false) {
          onStart();
          setTimeout(onDone, time);
        } else {
          view.transition(time, onStart, onDone);
        }
        return;
      }
      window.requestAnimationFrame(() => {
        const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
        const keepAdds = adds.filter(
          (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
        );
        const keepRemoves = removes.filter(
          (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
        );
        const newAdds = prevAdds.filter((name) => removes.indexOf(name) < 0).concat(keepAdds);
        const newRemoves = prevRemoves.filter((name) => adds.indexOf(name) < 0).concat(keepRemoves);
        dom_default.putSticky(el, "classes", (currentEl) => {
          currentEl.classList.remove(...newRemoves);
          currentEl.classList.add(...newAdds);
          return [newAdds, newRemoves];
        });
      });
    },
    setOrRemoveAttrs(el, sets, removes) {
      const [prevSets, prevRemoves] = dom_default.getSticky(el, "attrs", [[], []]);
      const alteredAttrs = sets.map(([attr, _val]) => attr).concat(removes);
      const newSets = prevSets.filter(([attr, _val]) => !alteredAttrs.includes(attr)).concat(sets);
      const newRemoves = prevRemoves.filter((attr) => !alteredAttrs.includes(attr)).concat(removes);
      if (sets.some(([attr, val]) => attr === "id" && el.getAttribute("id") !== val)) {
        dom_default.putPrivate(el, "clientsideIdAttribute", true);
      }
      dom_default.putSticky(el, "attrs", (currentEl) => {
        newRemoves.forEach((attr) => currentEl.removeAttribute(attr));
        newSets.forEach(([attr, val]) => currentEl.setAttribute(attr, val));
        return [newSets, newRemoves];
      });
    },
    hasAllClasses(el, classes) {
      return classes.every((name) => el.classList.contains(name));
    },
    isToggledOut(el, outClasses) {
      return !this.isVisible(el) || this.hasAllClasses(el, outClasses);
    },
    filterToEls(liveSocket2, sourceEl, { to }) {
      const defaultQuery = () => {
        if (typeof to === "string") {
          return document.querySelectorAll(to);
        } else if (to.closest) {
          const toEl = sourceEl.closest(to.closest);
          return toEl ? [toEl] : [];
        } else if (to.inner) {
          return sourceEl.querySelectorAll(to.inner);
        }
      };
      return to ? liveSocket2.jsQuerySelectorAll(sourceEl, to, defaultQuery) : [sourceEl];
    },
    defaultDisplay(el) {
      return { tr: "table-row", td: "table-cell" }[el.tagName.toLowerCase()] || "block";
    },
    transitionClasses(val) {
      if (!val) {
        return null;
      }
      let [trans, tStart, tEnd] = Array.isArray(val) ? val : [val.split(" "), [], []];
      trans = Array.isArray(trans) ? trans : trans.split(" ");
      tStart = Array.isArray(tStart) ? tStart : tStart.split(" ");
      tEnd = Array.isArray(tEnd) ? tEnd : tEnd.split(" ");
      return [trans, tStart, tEnd];
    }
  };
  var js_default = JS;
  var js_commands_default = (liveSocket2, eventType) => {
    return {
      exec(el, encodedJS) {
        liveSocket2.execJS(el, encodedJS, eventType);
      },
      show(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.show(
          eventType,
          owner,
          el,
          opts.display,
          js_default.transitionClasses(opts.transition),
          opts.time,
          opts.blocking
        );
      },
      hide(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.hide(
          eventType,
          owner,
          el,
          null,
          js_default.transitionClasses(opts.transition),
          opts.time,
          opts.blocking
        );
      },
      toggle(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        const inTransition = js_default.transitionClasses(opts.in);
        const outTransition = js_default.transitionClasses(opts.out);
        js_default.toggle(
          eventType,
          owner,
          el,
          opts.display,
          inTransition,
          outTransition,
          opts.time,
          opts.blocking
        );
      },
      addClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          classNames,
          [],
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      removeClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          [],
          classNames,
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      toggleClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.toggleClasses(
          el,
          classNames,
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      transition(el, transition, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          [],
          [],
          js_default.transitionClasses(transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      setAttribute(el, attr, val) {
        js_default.setOrRemoveAttrs(el, [[attr, val]], []);
      },
      removeAttribute(el, attr) {
        js_default.setOrRemoveAttrs(el, [], [attr]);
      },
      toggleAttribute(el, attr, val1, val2) {
        js_default.toggleAttr(el, attr, val1, val2);
      },
      push(el, type, opts = {}) {
        liveSocket2.withinOwners(el, (view) => {
          const _a = opts, { value } = _a, rest = __objRest(_a, ["value"]);
          const data = value || {};
          let e2 = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
          js_default.exec(e2, eventType, type, view, el, ["push", __spreadValues({ data }, rest)]);
        });
      },
      navigate(href, opts = {}) {
        ensureSameOrigin(href, "navigate");
        const customEvent = new CustomEvent("phx:exec");
        liveSocket2.historyRedirect(
          customEvent,
          href,
          opts.replace ? "replace" : "push",
          null,
          null
        );
      },
      patch(href, opts = {}) {
        ensureSameOrigin(href, "patch");
        const customEvent = new CustomEvent("phx:exec");
        liveSocket2.pushHistoryPatch(
          customEvent,
          href,
          opts.replace ? "replace" : "push",
          null
        );
      },
      ignoreAttributes(el, attrs) {
        js_default.ignoreAttrs(el, Array.isArray(attrs) ? attrs : [attrs]);
      }
    };
  };
  var HOOK_ID = "hookId";
  var DEAD_HOOK = "deadHook";
  var viewHookID = 1;
  var ViewHook = class _ViewHook {
    get liveSocket() {
      return this.__liveSocket();
    }
    /** @internal */
    static makeID() {
      return viewHookID++;
    }
    /** @internal */
    static elementID(el) {
      return dom_default.private(el, HOOK_ID);
    }
    /** @internal */
    static deadHook(el) {
      return dom_default.private(el, DEAD_HOOK) === true;
    }
    /** @internal */
    constructor(view, el, callbacks) {
      this.el = el;
      this.__attachView(view);
      this.__listeners = /* @__PURE__ */ new Set();
      this.__isDisconnected = false;
      dom_default.putPrivate(this.el, HOOK_ID, _ViewHook.makeID());
      if (view && view.isDead) {
        dom_default.putPrivate(this.el, DEAD_HOOK, true);
      }
      if (callbacks) {
        const protectedProps = /* @__PURE__ */ new Set([
          "el",
          "liveSocket",
          "__view",
          "__listeners",
          "__isDisconnected",
          "constructor",
          // Standard object properties
          // Core ViewHook API methods
          "js",
          "pushEvent",
          "pushEventTo",
          "handleEvent",
          "removeHandleEvent",
          "upload",
          "uploadTo",
          // Internal lifecycle callers
          "__mounted",
          "__updated",
          "__beforeUpdate",
          "__destroyed",
          "__reconnected",
          "__disconnected",
          "__cleanup__"
        ]);
        for (const key in callbacks) {
          if (Object.prototype.hasOwnProperty.call(callbacks, key)) {
            this[key] = callbacks[key];
            if (protectedProps.has(key)) {
              console.warn(
                `Hook object for element #${el.id} overwrites core property '${key}'!`
              );
            }
          }
        }
        const lifecycleMethods = [
          "mounted",
          "beforeUpdate",
          "updated",
          "destroyed",
          "disconnected",
          "reconnected"
        ];
        lifecycleMethods.forEach((methodName) => {
          if (callbacks[methodName] && typeof callbacks[methodName] === "function") {
            this[methodName] = callbacks[methodName];
          }
        });
      }
    }
    /** @internal */
    __attachView(view) {
      if (view) {
        this.__view = () => view;
        this.__liveSocket = () => view.liveSocket;
      } else {
        this.__view = () => {
          throw new Error(
            `hook not yet attached to a live view: ${this.el.outerHTML}`
          );
        };
        this.__liveSocket = () => {
          throw new Error(
            `hook not yet attached to a live view: ${this.el.outerHTML}`
          );
        };
      }
    }
    // Default lifecycle methods
    mounted() {
    }
    beforeUpdate(_toEl) {
    }
    updated() {
    }
    destroyed() {
    }
    disconnected() {
    }
    reconnected() {
    }
    // Internal lifecycle callers - called by the View
    /** @internal */
    __mounted() {
      this.mounted();
    }
    /** @internal */
    __updated() {
      this.updated();
    }
    /** @internal */
    __beforeUpdate(toEl) {
      this.beforeUpdate(toEl);
    }
    /** @internal */
    __destroyed() {
      this.destroyed();
      dom_default.deletePrivate(this.el, HOOK_ID);
    }
    /** @internal */
    __reconnected() {
      if (this.__isDisconnected) {
        this.__isDisconnected = false;
        this.reconnected();
      }
    }
    /** @internal */
    __disconnected() {
      if (!this.__isDisconnected) {
        this.__isDisconnected = true;
        this.disconnected();
      }
    }
    js() {
      return __spreadProps(__spreadValues({}, js_commands_default(this.__view().liveSocket, "hook")), {
        exec: (encodedJS) => {
          this.__view().liveSocket.execJS(this.el, encodedJS, "hook");
        }
      });
    }
    pushEvent(event, payload, onReply) {
      const promise = this.__view().pushHookEvent(
        this.el,
        null,
        event,
        payload || {}
      );
      if (onReply === void 0) {
        return promise.then(({ reply }) => reply);
      }
      promise.then(
        ({ reply, ref }) => onReply(reply, ref),
        () => {
        }
      );
    }
    pushEventTo(selectorOrTarget, event, payload, onReply) {
      if (onReply === void 0) {
        const targetPair = [];
        this.__view().withinTargets(
          selectorOrTarget,
          (view, targetCtx) => {
            targetPair.push({ view, targetCtx });
          }
        );
        const promises = targetPair.map(({ view, targetCtx }) => {
          return view.pushHookEvent(
            this.el,
            targetCtx,
            event,
            payload || {}
          );
        });
        return Promise.allSettled(promises);
      }
      this.__view().withinTargets(
        selectorOrTarget,
        (view, targetCtx) => {
          view.pushHookEvent(this.el, targetCtx, event, payload || {}).then(
            ({ reply, ref }) => onReply(reply, ref),
            () => {
            }
          );
        }
      );
    }
    handleEvent(event, callback) {
      const callbackRef = {
        event,
        callback: (customEvent) => callback(customEvent.detail)
      };
      window.addEventListener(
        `phx:${event}`,
        callbackRef.callback
      );
      this.__listeners.add(callbackRef);
      return callbackRef;
    }
    removeHandleEvent(ref) {
      window.removeEventListener(
        `phx:${ref.event}`,
        ref.callback
      );
      this.__listeners.delete(ref);
    }
    upload(name, files) {
      return this.__view().dispatchUploads(null, name, files);
    }
    uploadTo(selectorOrTarget, name, files) {
      return this.__view().withinTargets(
        selectorOrTarget,
        (view, targetCtx) => {
          view.dispatchUploads(targetCtx, name, files);
        }
      );
    }
    /** @internal */
    __cleanup__() {
      this.__listeners.forEach(
        (callbackRef) => this.removeHandleEvent(callbackRef)
      );
    }
  };
  var prependFormDataKey = (key, prefix) => {
    const isArray = key.endsWith("[]");
    let baseKey = isArray ? key.slice(0, -2) : key;
    baseKey = baseKey.replace(/([^\[\]]+)(\]?$)/, `${prefix}$1$2`);
    if (isArray) {
      baseKey += "[]";
    }
    return baseKey;
  };
  var View = class _View {
    static closestView(el) {
      const liveViewEl = el.closest(PHX_VIEW_SELECTOR);
      return liveViewEl ? dom_default.private(liveViewEl, "view") : null;
    }
    constructor(el, liveSocket2, parentView, flash = null, liveReferer = null) {
      this.rendered = null;
      this.isDead = false;
      this.liveSocket = liveSocket2;
      this.flash = flash;
      this.parent = parentView;
      this.root = parentView ? parentView.root : this;
      this.el = el;
      const boundView = dom_default.private(this.el, "view");
      if (boundView !== void 0 && boundView.isDead !== true) {
        this.logError(
          "view.duplicate-binding",
          `The DOM element for this view has already been bound to a view.

        An element can only ever be associated with a single view!
        Please ensure that you are not trying to initialize multiple LiveSockets on the same page.
        This could happen if you're accidentally trying to render your root layout more than once.
        Ensure that the template set on the LiveView is different than the root layout.
      `,
          { view: boundView },
          { attribution: "app" }
        );
        throw new Error("Cannot bind multiple views to the same DOM element.");
      }
      dom_default.putPrivate(this.el, "view", this);
      this.id = this.el.id;
      this.el.setAttribute(PHX_ROOT_ID, this.root.id);
      this.ref = 0;
      this.lastAckRef = null;
      this.childJoins = 0;
      this.loaderTimer = null;
      this.disconnectedTimer = null;
      this.pendingDiffs = [];
      this.pendingForms = /* @__PURE__ */ new Set();
      this.activeUploaders = /* @__PURE__ */ new Set();
      this.redirect = false;
      this.href = null;
      this.joinCount = this.parent ? this.parent.joinCount - 1 : 0;
      this.joinAttempts = 0;
      this.joinPending = true;
      this.destroyed = false;
      this.joinCallback = function(onDone) {
        onDone && onDone();
      };
      this.stopCallback = function() {
      };
      this.pendingJoinOps = [];
      this.viewHooks = {};
      this.formSubmits = [];
      this.children = this.parent ? null : {};
      this.root.children[this.id] = {};
      this.formsForRecovery = {};
      this.channel = this.liveSocket.channel(`lv:${this.id}`, () => {
        var _a;
        const url = this.href && this.expandURL(this.href);
        return {
          redirect: this.redirect ? url : void 0,
          url: this.redirect ? void 0 : url || void 0,
          params: this.connectParams(liveReferer),
          session: this.getSession(),
          static: this.getStatic(),
          flash: (_a = this.flash) != null ? _a : void 0,
          sticky: this.el.hasAttribute(PHX_STICKY)
        };
      });
      this.portalElementIds = /* @__PURE__ */ new Set();
    }
    setHref(href) {
      this.href = href;
    }
    setRedirect(href) {
      this.redirect = true;
      this.href = href;
    }
    isMain() {
      return this.el.hasAttribute(PHX_MAIN);
    }
    connectParams(liveReferer) {
      const params = this.liveSocket.params(this.el);
      const manifest = dom_default.all(document, `[${this.binding(PHX_TRACK_STATIC)}]`).map(
        (node) => "src" in node && node.src || "href" in node && node.href
      ).filter((url) => typeof url === "string");
      if (manifest.length > 0) {
        params["_track_static"] = manifest;
      }
      params["_mounts"] = this.joinCount;
      params["_mount_attempts"] = this.joinAttempts;
      params["_live_referer"] = liveReferer != null ? liveReferer : void 0;
      this.joinAttempts++;
      return params;
    }
    isConnected() {
      return this.channel.canPush();
    }
    getSession() {
      return this.el.getAttribute(PHX_SESSION);
    }
    getStatic() {
      const val = this.el.getAttribute(PHX_STATIC);
      return val === "" ? null : val;
    }
    destroy(callback = function() {
    }) {
      js_default.dropFocus(this);
      this.destroyAllChildren();
      this.destroyPortalElements();
      this.destroyed = true;
      this.activeUploaders.forEach((uploader) => uploader.cancel());
      this.activeUploaders.clear();
      dom_default.deletePrivate(this.el, "view");
      delete this.root.children[this.id];
      if (this.parent) {
        delete this.root.children[this.parent.id][this.id];
      }
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      const onFinished = () => {
        callback();
        for (const id in this.viewHooks) {
          this.destroyHook(this.viewHooks[id]);
        }
      };
      dom_default.markPhxChildDestroyed(this.el);
      this.log(
        "destroyed",
        () => ["the child has been removed from the parent"],
        {
          code: "view.child-destroyed"
        }
      );
      this.channel.leave().receive("ok", onFinished).receive("error", onFinished).receive("timeout", onFinished);
    }
    setContainerClasses(...classes) {
      this.el.classList.remove(
        PHX_CONNECTED_CLASS,
        PHX_LOADING_CLASS,
        PHX_ERROR_CLASS,
        PHX_CLIENT_ERROR_CLASS,
        PHX_SERVER_ERROR_CLASS
      );
      this.el.classList.add(...classes);
    }
    showLoader(timeout) {
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      if (timeout) {
        this.loaderTimer = setTimeout(() => this.showLoader(), timeout);
      } else {
        for (const id in this.viewHooks) {
          this.viewHooks[id].__disconnected();
        }
        this.setContainerClasses(PHX_LOADING_CLASS);
      }
    }
    execAll(binding) {
      dom_default.all(
        this.el,
        `[${binding}]`,
        (el) => this.liveSocket.execJS(el, el.getAttribute(binding))
      );
    }
    hideLoader() {
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      this.disconnectedTimer != null && clearTimeout(this.disconnectedTimer);
      this.setContainerClasses(PHX_CONNECTED_CLASS);
      this.execAll(this.binding("connected"));
    }
    triggerReconnected() {
      for (const id in this.viewHooks) {
        this.viewHooks[id].__reconnected();
      }
    }
    log(kind, msgCallback, diagnostic) {
      this.liveSocket.log(this, kind, msgCallback, diagnostic);
    }
    logError(code, message, metadata, context = { attribution: "unknown" }) {
      var _a;
      logError(code, message, metadata, __spreadValues({
        viewId: (_a = this.id) != null ? _a : this.el.id
      }, context));
    }
    transition(time, onStart, onDone = function() {
    }) {
      this.liveSocket.transition(time, onStart, onDone);
    }
    // calls the callback with the view and target element for the given phxTarget
    // targets can be:
    //  * an element itself, then it is simply passed to liveSocket.owner;
    //  * a CID (Component ID), then we first search the component's element in the DOM
    //  * a selector, then we search the selector in the DOM and call the callback
    //    for each element found with the corresponding owner view
    withinTargets(phxTarget, callback, dom = document) {
      if (phxTarget instanceof HTMLElement || phxTarget instanceof SVGElement) {
        return this.liveSocket.owner(
          phxTarget,
          (view) => callback(view, phxTarget)
        );
      }
      if (isCid(phxTarget)) {
        const target = dom_default.findComponent(this.id, phxTarget, dom);
        if (!target) {
          this.logError(
            "event.missing-component-target",
            `no component found matching phx-target of ${phxTarget}`,
            { target: phxTarget }
          );
        } else {
          callback(
            this,
            typeof phxTarget === "number" ? phxTarget : parseInt(phxTarget)
          );
        }
      } else {
        const targets = Array.from(dom.querySelectorAll(phxTarget));
        if (targets.length === 0) {
          this.logError(
            "event.missing-selector-target",
            `nothing found matching the phx-target selector "${phxTarget}"`,
            { target: phxTarget },
            { attribution: "app" }
          );
        }
        targets.forEach(
          (target) => this.liveSocket.owner(target, (view) => callback(view, target))
        );
      }
    }
    applyDiff(type, rawDiff, callback) {
      const clonedDiff = clone(rawDiff);
      this.log(type, () => ["received diff", clonedDiff], {
        code: `view.diff-${type}`,
        metadata: () => ({ diff: clonedDiff })
      });
      const { diff, reply, events, title } = Rendered.extract(rawDiff);
      const ev = events.reduce(
        (acc, args) => {
          if (args.length === 3 && args[2] == true) {
            acc.pre.push(args.slice(0, -1));
          } else {
            acc.post.push(args);
          }
          return acc;
        },
        { pre: [], post: [] }
      );
      this.liveSocket.dispatchEvents(ev.pre);
      const update = () => {
        callback({ diff, reply, events: ev.post });
        if (typeof title === "string" || type == "mount" && this.isMain()) {
          window.requestAnimationFrame(() => dom_default.putTitle(title));
        }
      };
      if ("onDocumentPatch" in this.liveSocket.domCallbacks) {
        this.liveSocket.triggerDOM("onDocumentPatch", [update]);
      } else {
        update();
      }
    }
    onJoin(resp) {
      const { rendered, container, liveview_version, pid } = resp;
      if (container) {
        const [tag, attrs] = container;
        this.el = dom_default.replaceRootContainer(this.el, tag, attrs);
        dom_default.putPrivate(this.el, "view", this);
      }
      this.childJoins = 0;
      this.joinPending = true;
      this.flash = null;
      if (this.root === this) {
        this.formsForRecovery = this.getFormsForRecovery();
      }
      if (this.isMain() && window.history.state === null) {
        browser_default.pushState("replace", {
          type: "patch",
          id: this.id,
          position: this.liveSocket.currentHistoryPosition
        });
      }
      if (liveview_version !== this.liveSocket.version()) {
        console.warn(
          `LiveView asset version mismatch. JavaScript version ${this.liveSocket.version()} vs. server ${liveview_version}. To avoid issues, please ensure that your assets use the same version as the server.`
        );
      }
      if (pid) {
        this.el.setAttribute(PHX_LV_PID, pid);
      }
      browser_default.dropLocal(
        this.liveSocket.localStorage,
        window.location.pathname,
        CONSECUTIVE_RELOADS
      );
      this.applyDiff("mount", rendered, ({ diff, events }) => {
        this.rendered = new Rendered(
          this.id,
          diff,
          () => this.liveSocket.RenderingBuffer
        );
        const [html, streams] = this.renderContainer(null, "join");
        this.dropPendingRefs();
        this.joinCount++;
        this.joinAttempts = 0;
        this.maybeRecoverForms(html, () => {
          this.onJoinComplete(resp, html, streams, events);
        });
      });
    }
    dropPendingRefs() {
      dom_default.all(document, `[${PHX_REF_SRC}="${this.refSrc()}"]`, (el) => {
        el.removeAttribute(PHX_REF_LOADING);
        el.removeAttribute(PHX_REF_SRC);
        el.removeAttribute(PHX_REF_LOCK);
      });
    }
    onJoinComplete({ live_patch }, html, streams, events) {
      if (this.joinCount > 1 || this.parent && !this.parent.isJoinPending()) {
        return this.applyJoinPatch(live_patch, html, streams, events);
      }
      const newChildren = dom_default.findPhxChildrenInFragment(html, this.id).filter(
        (toEl) => {
          const fromEl = toEl.id && this.el.querySelector(`[id="${toEl.id}"]`);
          const phxStatic = fromEl && fromEl.getAttribute(PHX_STATIC);
          if (phxStatic) {
            toEl.setAttribute(PHX_STATIC, phxStatic);
          }
          if (fromEl) {
            fromEl.setAttribute(PHX_ROOT_ID, this.root.id);
          }
          return this.joinChild(toEl);
        }
      );
      if (newChildren.length === 0) {
        if (this.parent) {
          this.root.pendingJoinOps.push([
            this,
            () => this.applyJoinPatch(live_patch, html, streams, events)
          ]);
          this.parent.ackJoin(this);
        } else {
          this.onAllChildJoinsComplete();
          this.applyJoinPatch(live_patch, html, streams, events);
        }
      } else {
        this.root.pendingJoinOps.push([
          this,
          () => this.applyJoinPatch(live_patch, html, streams, events)
        ]);
      }
    }
    attachTrueDocEl() {
      const el = dom_default.byId(this.id);
      if (!el) {
        throw new Error("unable to find root element for view");
      }
      this.el = el;
      dom_default.putPrivate(this.el, "view", this);
      this.el.setAttribute(PHX_ROOT_ID, this.root.id);
    }
    // this is invoked for dead and live views, so we must filter by
    // by owner to ensure we aren't duplicating hooks across disconnect
    // and connected states. This also handles cases where hooks exist
    // in a root layout with a LV in the body
    execNewMounted(parent = document) {
      let phxViewportTop = this.binding(PHX_VIEWPORT_TOP);
      let phxViewportBottom = this.binding(PHX_VIEWPORT_BOTTOM);
      this.all(
        parent,
        `[${phxViewportTop}], [${phxViewportBottom}]`,
        (hookEl) => {
          dom_default.maintainPrivateHooks(
            hookEl,
            hookEl,
            phxViewportTop,
            phxViewportBottom
          );
          this.maybeAddNewHook(hookEl);
        }
      );
      this.all(
        parent,
        `[${this.binding(PHX_HOOK)}], [data-phx-${PHX_HOOK}]`,
        (hookEl) => {
          this.maybeAddNewHook(hookEl);
        }
      );
      this.all(parent, `[${this.binding(PHX_MOUNTED)}]`, (el) => {
        this.maybeMounted(el);
      });
    }
    all(parent, selector, callback) {
      dom_default.all(parent, selector, (el) => {
        if (this.ownsElement(el)) {
          callback(el);
        }
      });
    }
    applyJoinPatch(live_patch, html, streams, events) {
      if (this.joinCount > 1) {
        if (this.pendingJoinOps.length) {
          this.pendingJoinOps.forEach((cb) => typeof cb === "function" && cb());
          this.pendingJoinOps = [];
        }
      }
      this.attachTrueDocEl();
      const patch = new DOMPatch(this, this.el, html, streams, null);
      patch.markPrunableContentForRemoval();
      this.performPatch(patch, false, true);
      this.joinNewChildren();
      this.execNewMounted();
      this.joinPending = false;
      this.liveSocket.dispatchEvents(events);
      this.applyPendingUpdates();
      if (live_patch) {
        const { kind, to } = live_patch;
        this.liveSocket.historyPatch(to, kind);
      }
      this.hideLoader();
      if (this.joinCount > 1) {
        this.triggerReconnected();
      }
      this.stopCallback();
    }
    triggerBeforeUpdateHook(fromEl, toEl) {
      this.liveSocket.triggerDOM("onBeforeElUpdated", [fromEl, toEl]);
      const hook = this.getHook(fromEl);
      const isIgnored = hook && dom_default.isIgnored(fromEl, this.binding(PHX_UPDATE));
      if (hook && !fromEl.isEqualNode(toEl) && !(isIgnored && isEqualObj(fromEl.dataset, toEl.dataset))) {
        hook.__beforeUpdate(toEl);
        return hook;
      }
    }
    maybeMounted(el) {
      const phxMounted = el.getAttribute(this.binding(PHX_MOUNTED));
      const hasBeenInvoked = phxMounted && dom_default.private(el, "mounted");
      if (phxMounted && !hasBeenInvoked) {
        this.liveSocket.execJS(el, phxMounted);
        dom_default.putPrivate(el, "mounted", true);
      }
    }
    maybeAddNewHook(el) {
      const newHook = this.addHook(el);
      if (newHook) {
        newHook.__mounted();
      }
    }
    performPatch(patch, pruneCids, isJoinPatch = false) {
      const removedEls = [];
      let phxChildrenAdded = false;
      const updatedHookIds = /* @__PURE__ */ new Set();
      const newHookIds = /* @__PURE__ */ new Set();
      this.liveSocket.triggerDOM("onPatchStart", [patch.targetContainer]);
      patch.afterAdded((el) => {
        this.liveSocket.triggerDOM("onNodeAdded", [el]);
        const phxViewportTop = this.binding(PHX_VIEWPORT_TOP);
        const phxViewportBottom = this.binding(PHX_VIEWPORT_BOTTOM);
        dom_default.maintainPrivateHooks(el, el, phxViewportTop, phxViewportBottom);
        this.maybeAddNewHook(el);
        if (el.getAttribute) {
          this.maybeMounted(el);
        }
      });
      patch.afterPhxChildAdded((el) => {
        if (dom_default.isPhxSticky(el)) {
          this.liveSocket.joinRootViews();
        } else {
          phxChildrenAdded = true;
        }
      });
      const hookAttr = this.binding(PHX_HOOK);
      const privateHookAttr = `data-phx-${PHX_HOOK}`;
      patch.beforeUpdated((fromEl, toEl) => {
        const hook = this.triggerBeforeUpdateHook(fromEl, toEl);
        if (hook) {
          if (fromEl.hasAttribute(hookAttr) && fromEl.getAttribute(hookAttr) !== toEl.getAttribute(hookAttr)) {
            this.destroyHook(hook);
            if (toEl.getAttribute(hookAttr)) {
              newHookIds.add(toEl.id);
            }
          } else {
            updatedHookIds.add(fromEl.id);
          }
        } else if (toEl.id && toEl.getAttribute && !this.getHook(fromEl)) {
          if (toEl.getAttribute(hookAttr) || toEl.getAttribute(privateHookAttr)) {
            newHookIds.add(toEl.id);
          }
        }
        js_default.onBeforeElUpdated(fromEl, toEl);
      });
      patch.afterUpdated((el) => {
        if (updatedHookIds.has(el.id)) {
          const hook = this.getHook(el);
          hook && hook.__updated();
        } else if (newHookIds.has(el.id)) {
          this.maybeAddNewHook(el);
        }
      });
      patch.afterDiscarded((el) => {
        if (el.nodeType === Node.ELEMENT_NODE) {
          removedEls.push(el);
        }
      });
      patch.afterTransitionsDiscarded(
        (els) => this.afterElementsRemoved(els, pruneCids)
      );
      patch.perform(isJoinPatch);
      this.afterElementsRemoved(removedEls, pruneCids);
      this.liveSocket.triggerDOM("onPatchEnd", [patch.targetContainer]);
      return phxChildrenAdded;
    }
    afterElementsRemoved(elements, pruneCids) {
      const destroyedCIDs = [];
      elements.forEach((parent) => {
        const components = dom_default.all(
          parent,
          `[${PHX_VIEW_REF}="${this.id}"][${PHX_COMPONENT}]`
        );
        const hooks = dom_default.all(
          parent,
          `[${this.binding(PHX_HOOK)}], [data-phx-hook]`
        );
        components.concat(parent).forEach((el) => {
          const cid = this.componentID(el);
          if (isCid(cid) && destroyedCIDs.indexOf(cid) === -1 && el.getAttribute(PHX_VIEW_REF) === this.id) {
            destroyedCIDs.push(cid);
          }
        });
        hooks.concat(parent).forEach((hookEl) => {
          const hook = this.getHook(hookEl);
          hook && this.destroyHook(hook);
        });
      });
      if (pruneCids) {
        this.maybePushComponentsDestroyed(destroyedCIDs);
      }
    }
    joinNewChildren() {
      dom_default.findPhxChildren(document, this.id).forEach((el) => this.joinChild(el));
    }
    maybeRecoverForms(html, callback) {
      var _a;
      const phxChange = this.binding("change");
      const oldForms = this.root.formsForRecovery;
      const template = document.createElement("template");
      template.innerHTML = html;
      if (!template.content.firstElementChild) {
        return callback();
      }
      dom_default.all(template.content, `[${PHX_PORTAL}]`).forEach((portalTemplate) => {
        var _a2;
        if (!(portalTemplate instanceof HTMLTemplateElement)) {
          return;
        }
        (_a2 = template.content.firstElementChild) == null ? void 0 : _a2.appendChild(
          portalTemplate.content.firstElementChild
        );
      });
      const rootEl = template.content.firstElementChild;
      rootEl.id = this.id;
      rootEl.setAttribute(PHX_ROOT_ID, this.root.id);
      rootEl.setAttribute(PHX_SESSION, this.getSession());
      rootEl.setAttribute(PHX_STATIC, (_a = this.getStatic()) != null ? _a : "");
      this.parent && rootEl.setAttribute(PHX_PARENT_ID, this.parent.id);
      dom_default.putPrivate(rootEl, "view", this);
      const formsToRecover = (
        // we go over all forms in the new DOM; because this is only the HTML for the current
        // view, we can be sure that all forms are owned by this view:
        dom_default.all(template.content, "form").filter((newForm) => newForm.id && oldForms[newForm.id]).filter((newForm) => !this.pendingForms.has(newForm.id)).filter(
          (newForm) => oldForms[newForm.id].getAttribute(phxChange) === newForm.getAttribute(phxChange)
        ).map((newForm) => {
          return [oldForms[newForm.id], newForm];
        })
      );
      if (formsToRecover.length === 0) {
        return callback();
      }
      formsToRecover.forEach(([oldForm, newForm], i) => {
        this.pendingForms.add(newForm.id);
        this.pushFormRecovery(
          oldForm,
          newForm,
          template.content.firstElementChild,
          () => {
            this.pendingForms.delete(newForm.id);
            if (i === formsToRecover.length - 1) {
              callback();
            }
          }
        );
      });
    }
    getChildById(id) {
      return this.root.children[this.id][id];
    }
    getDescendentByEl(el) {
      var _a;
      if (el.id === this.id) {
        return this;
      } else {
        return this.children && ((_a = this.children[el.getAttribute(PHX_PARENT_ID)]) == null ? void 0 : _a[el.id]);
      }
    }
    destroyDescendent(id) {
      for (const parentId in this.root.children) {
        for (const childId in this.root.children[parentId]) {
          if (childId === id) {
            return this.root.children[parentId][childId].destroy();
          }
        }
      }
    }
    joinChild(el) {
      const child = this.getChildById(el.id);
      if (!child) {
        const view = new _View(el, this.liveSocket, this);
        this.root.children[this.id][view.id] = view;
        view.join();
        this.childJoins++;
        return true;
      }
    }
    isJoinPending() {
      return this.joinPending;
    }
    ackJoin(_child) {
      this.childJoins--;
      if (this.childJoins === 0) {
        if (this.parent) {
          this.parent.ackJoin(this);
        } else {
          this.onAllChildJoinsComplete();
        }
      }
    }
    onAllChildJoinsComplete() {
      this.pendingForms.clear();
      this.formsForRecovery = {};
      this.joinCallback(() => {
        this.pendingJoinOps.forEach(([view, op]) => {
          if (!view.isDestroyed()) {
            op();
          }
        });
        this.pendingJoinOps = [];
      });
    }
    update(diff, events, isPending = false) {
      if (this.isJoinPending() || this.liveSocket.hasPendingLink() && this.root.isMain()) {
        if (!isPending) {
          this.pendingDiffs.push({ diff, events, joinCount: this.joinCount });
        }
        return false;
      }
      this.rendered.mergeDiff(diff);
      let phxChildrenAdded = false;
      if (this.rendered.isComponentOnlyDiff(diff)) {
        this.liveSocket.time("component patch complete", () => {
          const parentCids = dom_default.findExistingParentCIDs(
            this.id,
            this.rendered.componentCIDs(diff)
          );
          parentCids.forEach((parentCID) => {
            if (this.componentPatch(
              this.rendered.getComponent(diff, parentCID),
              parentCID
            )) {
              phxChildrenAdded = true;
            }
          });
        });
      } else if (!isEmpty(diff)) {
        this.liveSocket.time("full patch complete", () => {
          const [html, streams] = this.renderContainer(diff, "update");
          const patch = new DOMPatch(this, this.el, html, streams, null);
          phxChildrenAdded = this.performPatch(patch, true);
        });
      }
      this.liveSocket.dispatchEvents(events);
      if (phxChildrenAdded) {
        this.joinNewChildren();
      }
      return true;
    }
    renderContainer(diff, kind) {
      return this.liveSocket.time(`toString diff (${kind})`, () => {
        const tag = this.el.tagName;
        const cids = diff ? this.rendered.componentCIDs(diff) : null;
        const { buffer: html, streams } = this.rendered.toString(cids);
        return [`<${tag}>${html}</${tag}>`, streams];
      });
    }
    componentPatch(diff, cid) {
      if (isEmpty(diff))
        return false;
      const { buffer: html, streams } = this.rendered.componentToString(cid);
      const patch = new DOMPatch(this, this.el, html, streams, cid);
      const childrenAdded = this.performPatch(patch, true);
      return childrenAdded;
    }
    getHook(el) {
      return this.viewHooks[ViewHook.elementID(el)];
    }
    addHook(el) {
      const hookElId = ViewHook.elementID(el);
      if (el.getAttribute && !this.ownsElement(el)) {
        return;
      }
      if (hookElId && !this.viewHooks[hookElId]) {
        if (ViewHook.deadHook(el)) {
          return;
        }
        const hook = dom_default.getCustomElHook(el) || this.logError(
          "hook.custom-element-missing-hook",
          `no hook found for custom element: ${el.id}`,
          { el },
          { attribution: "app" }
        );
        this.viewHooks[hookElId] = hook;
        hook.__attachView(this);
        return hook;
      } else if (hookElId || !el.getAttribute) {
        return;
      } else {
        const hookName = el.getAttribute(`data-phx-${PHX_HOOK}`) || el.getAttribute(this.binding(PHX_HOOK));
        if (!hookName) {
          return;
        }
        const hookDefinition = this.liveSocket.getHookDefinition(hookName);
        if (hookDefinition) {
          if (!el.id) {
            this.logError(
              "hook.missing-id",
              `no DOM ID for hook "${hookName}". Hooks require a unique ID on each element.`,
              { el, hookName },
              { attribution: "app" }
            );
            return;
          }
          let hookInstance;
          try {
            if (typeof hookDefinition === "function" && hookDefinition.prototype instanceof ViewHook) {
              hookInstance = new hookDefinition(this, el);
            } else if (typeof hookDefinition === "object" && hookDefinition !== null) {
              hookInstance = new ViewHook(this, el, hookDefinition);
            } else {
              this.logError(
                "hook.invalid-definition",
                `Invalid hook definition for "${hookName}". Expected a class extending ViewHook or an object definition.`,
                { el, hookName },
                { attribution: "app" }
              );
              return;
            }
          } catch (e2) {
            const errorMessage = e2 instanceof Error ? e2.message : String(e2);
            this.logError(
              "hook.creation-failed",
              `Failed to create hook "${hookName}": ${errorMessage}`,
              { el, hookName, error: e2 },
              { attribution: "app" }
            );
            return;
          }
          this.viewHooks[ViewHook.elementID(hookInstance.el)] = hookInstance;
          return hookInstance;
        } else if (hookName !== null) {
          this.logError(
            "hook.unknown",
            `unknown hook found for "${hookName}"`,
            {
              el,
              hookName
            },
            { attribution: "app" }
          );
        }
      }
    }
    destroyHook(hook) {
      const hookId = ViewHook.elementID(hook.el);
      hook.__destroyed();
      hook.__cleanup__();
      delete this.viewHooks[hookId];
    }
    applyPendingUpdates() {
      this.pendingDiffs = this.pendingDiffs.filter(
        ({ diff, events, joinCount }) => {
          if (joinCount !== this.joinCount) {
            this.log(
              "update",
              () => ["discarded diff from previous join", diff],
              {
                code: "view.stale-diff-discarded",
                metadata: () => ({ joinCount, currentJoinCount: this.joinCount })
              }
            );
            return false;
          }
          return !this.update(diff, events, true);
        }
      );
      this.eachChild((child) => child.applyPendingUpdates());
    }
    eachChild(callback) {
      const children = this.root.children[this.id] || {};
      for (const id in children) {
        callback(this.getChildById(id));
      }
    }
    onChannel(event, cb) {
      this.liveSocket.onChannel(this.channel, event, (resp) => {
        if (this.isJoinPending() && !["redirect", "live_redirect"].includes(event)) {
          if (this.joinCount > 1) {
            this.pendingJoinOps.push(() => cb(resp));
          } else {
            this.root.pendingJoinOps.push([this, () => cb(resp)]);
          }
        } else {
          this.liveSocket.requestDOMUpdate(() => cb(resp));
        }
      });
    }
    bindChannel() {
      this.liveSocket.onChannel(this.channel, "diff", (rawDiff) => {
        this.liveSocket.requestDOMUpdate(() => {
          this.applyDiff(
            "update",
            rawDiff,
            ({ diff, events }) => this.update(diff, events)
          );
        });
      });
      this.onChannel(
        "redirect",
        ({ to, flash }) => this.onRedirect({ to, flash })
      );
      this.onChannel("live_patch", (redir) => this.onLivePatch(redir));
      this.onChannel("live_redirect", (redir) => this.onLiveRedirect(redir));
      this.channel.onError((reason) => this.onError(reason));
      this.channel.onClose((reason) => this.onClose(reason));
    }
    destroyAllChildren() {
      this.eachChild((child) => child.destroy());
    }
    onLiveRedirect(redir) {
      const { to, kind, flash } = redir;
      const url = this.expandURL(to);
      const e2 = new CustomEvent("phx:server-navigate", {
        detail: { to, kind, flash }
      });
      this.liveSocket.historyRedirect(e2, url, kind, flash);
    }
    onLivePatch(redir) {
      const { to, kind } = redir;
      this.href = this.expandURL(to);
      this.liveSocket.historyPatch(to, kind);
    }
    expandURL(to) {
      return to.startsWith("/") ? `${window.location.protocol}//${window.location.host}${to}` : to;
    }
    onRedirect({
      to,
      flash,
      reloadToken
    }) {
      this.liveSocket.redirect(to, flash != null ? flash : null, reloadToken != null ? reloadToken : null);
    }
    isDestroyed() {
      return this.destroyed;
    }
    joinDead() {
      this.isDead = true;
    }
    join(callback) {
      this.showLoader(this.liveSocket.loaderTimeout);
      this.bindChannel();
      if (this.isMain()) {
        this.stopCallback = this.liveSocket.withPageLoading({
          to: this.href,
          kind: "initial"
        });
      }
      this.joinCallback = (onDone) => {
        onDone = onDone || function() {
        };
        callback ? callback(this.joinCount, onDone) : onDone();
      };
      this.wrapPush(() => this.channel.join(), {
        ok: (resp) => this.liveSocket.requestDOMUpdate(() => this.onJoin(resp)),
        error: (error) => this.onJoinError(error),
        timeout: () => this.onJoinError({ reason: "timeout" })
      });
    }
    onJoinError(resp) {
      if (resp.events) {
        this.liveSocket.dispatchEvents(resp.events);
      }
      if (resp.reason === "reload") {
        this.log(
          "error",
          () => [
            `failed mount with ${resp.status}. Falling back to page reload`,
            resp
          ],
          {
            code: "view.mount-reload",
            level: "error",
            metadata: () => ({ status: resp.status }),
            context: { attribution: "app" }
          }
        );
        this.onRedirect({
          to: this.liveSocket.main.href,
          reloadToken: resp.token
        });
        return;
      } else if (resp.reason === "unauthorized" || resp.reason === "stale") {
        this.log(
          "error",
          () => [
            "unauthorized live_redirect. Falling back to page request",
            resp
          ],
          {
            code: "view.unauthorized-live-redirect",
            level: "error",
            metadata: () => ({ reason: resp.reason }),
            context: { attribution: "app" }
          }
        );
        this.onRedirect({ to: this.liveSocket.main.href, flash: this.flash });
        return;
      }
      if (resp.redirect || resp.live_redirect) {
        this.joinPending = false;
        this.channel.leave();
      }
      if (resp.redirect) {
        return this.onRedirect(resp.redirect);
      }
      if (resp.live_redirect) {
        return this.onLiveRedirect(resp.live_redirect);
      }
      const timedOut = resp.reason === "timeout";
      const attribution = timedOut || resp.source === "transport" ? "network" : "app";
      this.log(
        "error",
        () => [timedOut ? "join timed out" : "unable to join", resp],
        {
          code: timedOut ? "view.join-timeout" : "view.join-failed",
          level: "error",
          metadata: () => timedOut ? { error: resp } : { response: resp },
          context: { attribution }
        }
      );
      if (this.isMain()) {
        this.displayError(
          [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
          { unstructuredError: resp, errorKind: "server" }
        );
        if (this.liveSocket.isConnected()) {
          this.liveSocket.reloadWithJitter(this);
        }
      } else {
        if (this.joinAttempts >= MAX_CHILD_JOIN_ATTEMPTS) {
          this.root.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: resp, errorKind: "server" }
          );
          this.log(
            "error",
            () => [
              `giving up trying to mount after ${MAX_CHILD_JOIN_ATTEMPTS} tries`,
              resp
            ],
            {
              code: "view.mount-attempts-exhausted",
              level: "error",
              metadata: () => ({
                attempts: MAX_CHILD_JOIN_ATTEMPTS,
                response: resp
              })
            }
          );
          this.destroy();
          return;
        }
        const trueChildEl = dom_default.byId(this.el.id);
        if (trueChildEl) {
          dom_default.mergeAttrs(trueChildEl, this.el);
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: resp, errorKind: "server" }
          );
          this.el = trueChildEl;
        } else {
          this.destroy();
        }
      }
    }
    onClose(reason) {
      if (this.isDestroyed()) {
        return;
      }
      if (this.isMain() && this.liveSocket.hasPendingLink() && reason !== "leave") {
        return this.liveSocket.reloadWithJitter(this);
      }
      this.destroyAllChildren();
      this.liveSocket.dropActiveElement(this);
      if (this.liveSocket.isUnloaded()) {
        this.showLoader(BEFORE_UNLOAD_LOADER_TIMEOUT);
      }
    }
    onError(reason) {
      this.onClose(reason);
      if (this.liveSocket.isConnected()) {
        this.log("error", () => ["view crashed", reason], {
          code: "view.crashed",
          level: "error",
          metadata: () => ({ reason }),
          context: { attribution: "app" }
        });
      }
      if (!this.liveSocket.isUnloaded()) {
        if (this.liveSocket.isConnected()) {
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: reason, errorKind: "server" }
          );
        } else {
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_CLIENT_ERROR_CLASS],
            { unstructuredError: reason, errorKind: "client" }
          );
        }
      }
    }
    displayError(classes, details = {}) {
      if (this.isMain()) {
        dom_default.dispatchEvent(window, "phx:page-loading-start", {
          detail: __spreadValues({ to: this.href, kind: "error" }, details)
        });
      }
      this.showLoader();
      this.setContainerClasses(...classes);
      this.delayedDisconnected();
    }
    delayedDisconnected() {
      this.disconnectedTimer = setTimeout(() => {
        this.execAll(this.binding("disconnected"));
      }, this.liveSocket.disconnectedTimeout);
    }
    wrapPush(callerPush, receives) {
      const latency = this.liveSocket.getLatencySim();
      const withLatency = latency ? (cb) => setTimeout(() => !this.isDestroyed() && cb(), latency) : (cb) => !this.isDestroyed() && cb();
      withLatency(() => {
        callerPush().receive(
          "ok",
          (resp) => withLatency(() => receives.ok && receives.ok(resp))
        ).receive(
          "error",
          (reason) => withLatency(() => receives.error && receives.error(reason))
        ).receive(
          "timeout",
          () => withLatency(() => receives.timeout && receives.timeout())
        );
      });
    }
    pushWithReply(refGenerator, event, payload) {
      if (!this.isConnected()) {
        return Promise.resolve({
          type: "error",
          error: "no connection",
          context: { attribution: "network" }
        });
      }
      const [ref, [el], opts] = refGenerator ? refGenerator({ payload }) : [null, [], {}];
      const oldJoinCount = this.joinCount;
      let onLoadingDone = function() {
      };
      if (opts.page_loading) {
        onLoadingDone = this.liveSocket.withPageLoading({
          kind: "element",
          target: el
        });
      }
      if (typeof payload.cid !== "number") {
        delete payload.cid;
      }
      return new Promise((resolve) => {
        this.wrapPush(() => this.channel.push(event, payload, PUSH_TIMEOUT), {
          ok: (resp) => {
            if (ref !== null) {
              this.lastAckRef = ref;
            }
            const finish = (hookReply) => {
              if (resp.redirect) {
                this.onRedirect(resp.redirect);
              }
              if (resp.live_patch) {
                this.onLivePatch(resp.live_patch);
              }
              if (resp.live_redirect) {
                this.onLiveRedirect(resp.live_redirect);
              }
              onLoadingDone();
              resolve({ type: "ok", resp, reply: hookReply, ref });
            };
            if (resp.diff) {
              this.liveSocket.requestDOMUpdate(() => {
                this.applyDiff("update", resp.diff, ({ diff, reply, events }) => {
                  if (ref !== null) {
                    this.undoRefs(ref, payload.event);
                  }
                  this.update(diff, events);
                  finish(reply);
                });
              });
            } else {
              if (ref !== null) {
                this.undoRefs(ref, payload.event);
              }
              finish(null);
            }
          },
          error: (reason) => {
            onLoadingDone();
            resolve({
              type: "error",
              error: `failed with reason: ${JSON.stringify(reason)}`,
              context: {
                attribution: "app"
              }
            });
          },
          timeout: () => {
            onLoadingDone();
            resolve({
              type: "error",
              error: "push timeout",
              context: { attribution: "network" }
            });
            if (this.joinCount === oldJoinCount) {
              this.liveSocket.reloadWithJitter(this, () => {
                this.log(
                  "timeout",
                  () => [
                    "received timeout while communicating with server. Falling back to hard refresh for recovery"
                  ],
                  {
                    code: "view.push-timeout-recovery",
                    level: "error",
                    context: { attribution: "network" }
                  }
                );
              });
            }
          }
        });
      });
    }
    undoRefs(ref, phxEvent, onlyEls) {
      if (!this.isConnected()) {
        return;
      }
      const selector = `[${PHX_REF_SRC}="${this.refSrc()}"]`;
      if (onlyEls) {
        onlyEls = new Set(onlyEls);
        dom_default.all(document, selector, (parent) => {
          if (onlyEls && !onlyEls.has(parent)) {
            return;
          }
          dom_default.all(
            parent,
            selector,
            (child) => this.undoElRef(child, ref, phxEvent)
          );
          this.undoElRef(parent, ref, phxEvent);
        });
      } else {
        dom_default.all(document, selector, (el) => this.undoElRef(el, ref, phxEvent));
      }
    }
    undoElRef(el, ref, phxEvent) {
      const elRef = new ElementRef(el);
      elRef.maybeUndo(ref, phxEvent, (clonedTree) => {
        const patch = new DOMPatch(this, el, clonedTree, /* @__PURE__ */ new Set(), null, {
          undoRef: ref
        });
        const phxChildrenAdded = this.performPatch(patch, true);
        dom_default.all(
          el,
          `[${PHX_REF_SRC}="${this.refSrc()}"]`,
          (child) => this.undoElRef(child, ref, phxEvent)
        );
        if (phxChildrenAdded) {
          this.joinNewChildren();
        }
      });
    }
    refSrc() {
      return this.el.id;
    }
    putRef(elements, phxEvent, eventType, opts = {}) {
      const newRef = this.ref++;
      const disableWith = this.binding(PHX_DISABLE_WITH);
      if (opts.loading) {
        const loadingEls = dom_default.all(document, opts.loading).map((el) => {
          return { el, lock: true, loading: true };
        });
        elements = elements.concat(loadingEls);
      }
      for (const { el, lock, loading } of elements) {
        if (!lock && !loading) {
          throw new Error("putRef requires lock or loading");
        }
        el.setAttribute(PHX_REF_SRC, this.refSrc());
        if (loading) {
          el.setAttribute(PHX_REF_LOADING, newRef.toString());
        }
        if (lock) {
          el.setAttribute(PHX_REF_LOCK, newRef.toString());
        }
        if (!loading || opts.submitter && !(el === opts.submitter || el === opts.form)) {
          continue;
        }
        const lockCompletePromise = new Promise((resolve) => {
          el.addEventListener(`phx:undo-lock:${newRef}`, () => resolve(detail), {
            once: true
          });
        });
        const loadingCompletePromise = new Promise((resolve) => {
          el.addEventListener(
            `phx:undo-loading:${newRef}`,
            () => resolve(detail),
            { once: true }
          );
        });
        el.classList.add(`phx-${eventType}-loading`);
        const disableText = el.getAttribute(disableWith);
        if (disableText !== null) {
          if (!el.getAttribute(PHX_DISABLE_WITH_RESTORE)) {
            el.setAttribute(PHX_DISABLE_WITH_RESTORE, el.textContent || "");
          }
          if (disableText !== "") {
            el.textContent = disableText;
          }
          el.setAttribute(
            PHX_DISABLED,
            el.getAttribute(PHX_DISABLED) || ("disabled" in el ? String(el.disabled) : "")
          );
          el.setAttribute("disabled", "");
        }
        const detail = {
          event: phxEvent,
          eventType,
          ref: newRef,
          isLoading: loading,
          isLocked: lock,
          lockElements: elements.filter(({ lock: lock2 }) => lock2).map(({ el: el2 }) => el2),
          loadingElements: elements.filter(({ loading: loading2 }) => loading2).map(({ el: el2 }) => el2),
          unlock: (els) => {
            els = Array.isArray(els) ? els : [els];
            this.undoRefs(newRef, phxEvent, els);
          },
          lockComplete: lockCompletePromise,
          loadingComplete: loadingCompletePromise,
          lock: (lockEl) => {
            return new Promise((resolve) => {
              if (this.isAcked(newRef)) {
                return resolve(detail);
              }
              lockEl.setAttribute(PHX_REF_LOCK, newRef);
              lockEl.setAttribute(PHX_REF_SRC, this.refSrc());
              lockEl.addEventListener(
                `phx:undo-lock:${newRef}`,
                () => resolve(detail),
                { once: true }
              );
            });
          }
        };
        if (opts.payload) {
          detail["payload"] = opts.payload;
        }
        if (opts.target) {
          detail["target"] = opts.target;
        }
        if (opts.originalEvent) {
          detail["originalEvent"] = opts.originalEvent;
        }
        el.dispatchEvent(
          new CustomEvent("phx:push", {
            detail,
            bubbles: true,
            cancelable: false
          })
        );
        if (phxEvent) {
          el.dispatchEvent(
            new CustomEvent(`phx:push:${phxEvent}`, {
              detail,
              bubbles: true,
              cancelable: false
            })
          );
        }
      }
      return [newRef, elements.map(({ el }) => el), opts];
    }
    isAcked(ref) {
      return this.lastAckRef !== null && this.lastAckRef >= ref;
    }
    componentID(el) {
      const cid = el.getAttribute && el.getAttribute(PHX_COMPONENT);
      return cid ? parseInt(cid) : null;
    }
    targetComponentID(target, targetCtx, opts = {}) {
      if (isCid(targetCtx)) {
        return targetCtx;
      }
      const cidOrSelector = opts.target || target.getAttribute(this.binding("target"));
      if (isCid(cidOrSelector)) {
        return typeof cidOrSelector === "number" ? cidOrSelector : parseInt(cidOrSelector);
      } else if (targetCtx && (cidOrSelector !== null || opts.target)) {
        return this.closestComponentID(targetCtx);
      } else {
        return null;
      }
    }
    closestComponentID(targetCtx) {
      if (isCid(targetCtx)) {
        return targetCtx;
      } else if (targetCtx) {
        return maybe(
          // We either use the closest data-phx-component binding, or -
          // in case of portals - continue with the portal source.
          // This is necessary if teleporting an element outside of its LiveComponent.
          targetCtx.closest(`[${PHX_COMPONENT}],[${PHX_TELEPORTED_SRC}]`),
          (el) => {
            if (el.hasAttribute(PHX_COMPONENT)) {
              return this.ownsElement(el) && this.componentID(el);
            }
            if (el.hasAttribute(PHX_TELEPORTED_SRC)) {
              const portalParent = dom_default.byId(el.getAttribute(PHX_TELEPORTED_SRC));
              return this.closestComponentID(portalParent);
            }
          }
        );
      } else {
        return null;
      }
    }
    pushHookEvent(el, targetCtx, event, payload) {
      if (!this.isConnected()) {
        this.log(
          "hook",
          () => [
            "unable to push hook event. LiveView not connected",
            { event, payload }
          ],
          {
            code: "hook.push-disconnected",
            metadata: () => ({ event, payload }),
            context: { attribution: "network" }
          }
        );
        return Promise.reject(
          new Error("unable to push hook event. LiveView not connected")
        );
      }
      const refGenerator = () => this.putRef([{ el, loading: true, lock: true }], event, "hook", {
        payload,
        target: targetCtx
      });
      return this.pushWithReply(refGenerator, "event", {
        type: "hook",
        event,
        value: payload,
        cid: this.closestComponentID(targetCtx)
      }).then((result) => {
        if (result.type === "error") {
          throw new Error("Failed to push hook event: " + result.error);
        }
        return { reply: result.reply, ref: result.ref };
      });
    }
    extractMeta(el, meta, value) {
      const prefix = this.binding("value-");
      for (let i = 0; i < el.attributes.length; i++) {
        if (!meta) {
          meta = {};
        }
        const name = el.attributes[i].name;
        if (name.startsWith(prefix)) {
          meta[name.replace(prefix, "")] = el.getAttribute(name);
        }
      }
      if (el.value !== void 0 && !(el instanceof HTMLFormElement)) {
        if (!meta) {
          meta = {};
        }
        meta.value = el.value;
        if (el.tagName === "INPUT" && CHECKABLE_INPUTS.indexOf(el.type) >= 0 && !el.checked) {
          delete meta.value;
        }
      }
      if (value) {
        if (!meta) {
          meta = {};
        }
        for (const key in value) {
          meta[key] = value[key];
        }
      }
      return meta;
    }
    serializeForm(form, opts = {}, onlyNames = []) {
      const { submitter } = opts;
      let injectedElement;
      if (submitter && submitter.name) {
        const input = document.createElement("input");
        input.type = "hidden";
        const formId = submitter.getAttribute("form");
        if (formId) {
          input.setAttribute("form", formId);
        }
        input.name = submitter.name;
        input.value = submitter.value;
        submitter.parentElement.insertBefore(input, submitter);
        injectedElement = input;
      }
      const formData = new FormData(form);
      const toRemove = [];
      formData.forEach((val, key, _index) => {
        if (val instanceof File) {
          toRemove.push(key);
        }
      });
      toRemove.forEach((key) => formData.delete(key));
      const params = new URLSearchParams();
      const { inputsUnused, onlyHiddenInputs } = Array.from(form.elements).reduce(
        (acc, input) => {
          if (!dom_default.isFormAssociated(input)) {
            return acc;
          }
          const { inputsUnused: inputsUnused2, onlyHiddenInputs: onlyHiddenInputs2 } = acc;
          const key = input.name;
          if (!key) {
            return acc;
          }
          if (inputsUnused2[key] === void 0) {
            inputsUnused2[key] = true;
          }
          if (onlyHiddenInputs2[key] === void 0) {
            onlyHiddenInputs2[key] = true;
          }
          const inputSkipUnusedField = input.hasAttribute(
            this.binding(PHX_NO_UNUSED_FIELD)
          );
          const isUsed = dom_default.private(input, PHX_HAS_FOCUSED) || dom_default.private(input, PHX_HAS_SUBMITTED) || inputSkipUnusedField;
          const isHidden = input.type === "hidden";
          inputsUnused2[key] = inputsUnused2[key] && !isUsed;
          onlyHiddenInputs2[key] = onlyHiddenInputs2[key] && isHidden;
          return acc;
        },
        { inputsUnused: {}, onlyHiddenInputs: {} }
      );
      const formSkipUnusedFields = form.hasAttribute(
        this.binding(PHX_NO_UNUSED_FIELD)
      );
      for (const [key, val] of formData.entries()) {
        if (onlyNames.length === 0 || onlyNames.indexOf(key) >= 0) {
          const isUnused = inputsUnused[key];
          const hidden = onlyHiddenInputs[key];
          const skipUnusedCheck = formSkipUnusedFields;
          if (!skipUnusedCheck && isUnused && !(submitter && submitter.name == key) && !hidden) {
            params.append(prependFormDataKey(key, "_unused_"), "");
          }
          if (typeof val === "string") {
            params.append(key, val);
          }
        }
      }
      if (submitter && injectedElement) {
        submitter.parentElement.removeChild(injectedElement);
      }
      return params.toString();
    }
    pushEvent(type, el, targetCtx, phxEvent, meta, opts = {}, onReply) {
      this.pushWithReply(
        (maybePayload) => this.putRef([{ el, loading: true, lock: true }], phxEvent, type, __spreadProps(__spreadValues({}, opts), {
          payload: maybePayload == null ? void 0 : maybePayload.payload
        })),
        "event",
        {
          type,
          event: phxEvent,
          value: this.extractMeta(el, meta, opts.value),
          cid: this.targetComponentID(el, targetCtx, opts)
        }
      ).then((result) => {
        if (result.type === "ok") {
          onReply && onReply(result.reply);
        } else {
          this.logError(
            "event.push-failed",
            "Failed to push event",
            {
              error: result.error,
              type,
              phxEvent,
              el
            },
            result.context
          );
        }
      });
    }
    pushFileProgress(fileEl, entryRef, progress, onReply = function() {
    }) {
      this.liveSocket.withinOwners(fileEl.form, (view, targetCtx) => {
        view.pushWithReply(null, "progress", {
          event: fileEl.getAttribute(view.binding(PHX_PROGRESS)),
          ref: fileEl.getAttribute(PHX_UPLOAD_REF),
          entry_ref: entryRef,
          progress,
          cid: view.targetComponentID(fileEl.form, targetCtx)
        }).then((result) => {
          if (result.type === "ok") {
            onReply();
          } else {
            view.logError(
              "upload.progress-push-failed",
              "Failed to push file progress",
              { error: result.error, fileEl, entryRef, progress },
              result.context
            );
          }
        });
      });
    }
    pushInput(inputEl, targetCtx, forceCid, phxEvent, opts, callback) {
      if (!inputEl.form) {
        throw new Error("form events require the input to be inside a form");
      }
      let uploads;
      const cid = isCid(forceCid) ? forceCid : this.targetComponentID(inputEl.form, targetCtx, opts);
      const refGenerator = (maybePayload) => {
        return this.putRef(
          [
            { el: inputEl, loading: true, lock: true },
            { el: inputEl.form, loading: true, lock: true }
          ],
          phxEvent,
          "change",
          __spreadProps(__spreadValues({}, opts), { payload: maybePayload == null ? void 0 : maybePayload.payload })
        );
      };
      let formData;
      const meta = this.extractMeta(inputEl.form, {}, opts.value);
      const serializeOpts = {};
      if (inputEl instanceof HTMLButtonElement) {
        serializeOpts.submitter = inputEl;
      }
      if (inputEl.getAttribute(this.binding("change"))) {
        formData = this.serializeForm(inputEl.form, serializeOpts, [
          inputEl.name
        ]);
      } else {
        formData = this.serializeForm(inputEl.form, serializeOpts);
      }
      if (dom_default.isUploadInput(inputEl) && inputEl.files && inputEl.files.length > 0) {
        LiveUploader.trackFiles(inputEl, Array.from(inputEl.files));
      }
      uploads = LiveUploader.serializeUploads(inputEl);
      const event = {
        type: "form",
        event: phxEvent,
        value: formData,
        meta: __spreadValues({
          // no target was implicitly sent as "undefined" in LV <= 1.0.5, therefore
          // we have to keep it. In 1.0.6 we switched from passing meta as URL encoded data
          // to passing it directly in the event, but the JSON encode would drop keys with
          // undefined values.
          _target: opts._target || "undefined"
        }, meta),
        uploads,
        cid
      };
      this.pushWithReply(refGenerator, "event", event).then((result) => {
        if (result.type === "ok") {
          if (dom_default.isUploadInput(inputEl) && dom_default.isAutoUpload(inputEl)) {
            ElementRef.onUnlock(inputEl, () => {
              if (LiveUploader.filesAwaitingPreflight(inputEl).length > 0) {
                const [ref, _els] = refGenerator();
                this.undoRefs(ref, phxEvent, [inputEl.form]);
                this.uploadFiles(
                  inputEl.form,
                  phxEvent,
                  targetCtx,
                  ref,
                  cid,
                  (_uploads) => {
                    callback && callback(result.resp);
                    this.triggerAwaitingSubmit(inputEl.form, phxEvent);
                    this.undoRefs(ref, phxEvent);
                  }
                );
              }
            });
          } else {
            callback && callback(result.resp);
          }
        } else {
          this.logError(
            "event.input-push-failed",
            "Failed to push input event",
            {
              error: result.error,
              inputEl,
              phxEvent
            },
            result.context
          );
        }
      });
    }
    triggerAwaitingSubmit(formEl, phxEvent) {
      const awaitingSubmit = this.getScheduledSubmit(formEl);
      if (awaitingSubmit) {
        const [_el, _ref, _opts, callback] = awaitingSubmit;
        this.cancelSubmit(formEl, phxEvent);
        callback();
      }
    }
    getScheduledSubmit(formEl) {
      return this.formSubmits.find(
        ([el, _ref, _opts, _callback]) => el.isSameNode(formEl)
      );
    }
    scheduleSubmit(formEl, ref, opts, callback) {
      if (this.getScheduledSubmit(formEl)) {
        return true;
      }
      this.formSubmits.push([formEl, ref, opts, callback]);
    }
    cancelSubmit(formEl, phxEvent) {
      this.formSubmits = this.formSubmits.filter(
        ([el, ref, _opts, _callback]) => {
          if (el.isSameNode(formEl)) {
            this.undoRefs(ref, phxEvent);
            return false;
          } else {
            return true;
          }
        }
      );
    }
    disableForm(formEl, phxEvent, opts = {}) {
      const filterIgnored = (el) => {
        const userIgnored = closestPhxBinding(
          el,
          `${this.binding(PHX_UPDATE)}=ignore`,
          el.form
        );
        return !(userIgnored || closestPhxBinding(el, "data-phx-update=ignore", el.form));
      };
      const filterDisables = (el) => {
        return el.hasAttribute(this.binding(PHX_DISABLE_WITH));
      };
      const filterButton = (el) => el.tagName == "BUTTON";
      const filterInput = (el) => ["INPUT", "TEXTAREA"].includes(el.tagName);
      const formElements = Array.from(formEl.elements);
      const disables = formElements.filter(filterDisables);
      const buttons = formElements.filter(filterButton).filter(filterIgnored);
      const inputs = formElements.filter(filterInput).filter(filterIgnored);
      buttons.forEach((button) => {
        button.setAttribute(PHX_DISABLED, button.disabled.toString());
        button.disabled = true;
      });
      inputs.forEach((input) => {
        input.setAttribute(PHX_READONLY, input.readOnly.toString());
        input.readOnly = true;
        if (input instanceof HTMLInputElement && input.files) {
          input.setAttribute(PHX_DISABLED, input.disabled.toString());
          input.disabled = true;
        }
      });
      const formEls = disables.concat(buttons).concat(inputs).map((el) => {
        return { el, loading: true, lock: true };
      });
      const els = [
        { el: formEl, loading: true, lock: false },
        ...formEls
      ].reverse();
      return this.putRef(els, phxEvent, "submit", opts);
    }
    pushFormSubmit(formEl, targetCtx, phxEvent, submitter, opts, onReply) {
      const refGenerator = (maybePayload) => this.disableForm(formEl, phxEvent, __spreadProps(__spreadValues({}, opts), {
        form: formEl,
        payload: maybePayload == null ? void 0 : maybePayload.payload,
        submitter
      }));
      dom_default.putPrivate(formEl, "submitter", submitter);
      const cid = this.targetComponentID(formEl, targetCtx);
      if (LiveUploader.hasUploadErrors(formEl)) {
        return this.cancelSubmit(formEl, phxEvent);
      } else if (LiveUploader.hasUploadsInProgress(formEl)) {
        const [ref, _els] = refGenerator();
        const push = () => this.pushFormSubmit(
          formEl,
          targetCtx,
          phxEvent,
          submitter,
          opts,
          onReply
        );
        return this.scheduleSubmit(formEl, ref, opts, push);
      } else if (LiveUploader.inputsAwaitingPreflight(formEl).length > 0) {
        const [ref, els] = refGenerator();
        const proxyRefGen = () => [ref, els, opts];
        this.uploadFiles(formEl, phxEvent, targetCtx, ref, cid, (_uploads) => {
          if (LiveUploader.inputsAwaitingPreflight(formEl).length > 0) {
            return this.undoRefs(ref, phxEvent);
          }
          const meta = this.extractMeta(formEl, {}, opts.value);
          const formData = this.serializeForm(formEl, { submitter });
          this.pushWithReply(proxyRefGen, "event", {
            type: "form",
            event: phxEvent,
            value: formData,
            meta,
            cid
          }).then((result) => {
            if (result.type === "ok") {
              onReply(result.resp);
            } else {
              this.logError(
                "event.submit-push-failed",
                "Failed to push form submit",
                {
                  error: result.error,
                  phxEvent,
                  formEl
                },
                result.context
              );
            }
          });
        });
      } else if (!(formEl.hasAttribute(PHX_REF_SRC) && formEl.classList.contains("phx-submit-loading"))) {
        const meta = this.extractMeta(formEl, {}, opts.value);
        const formData = this.serializeForm(formEl, { submitter });
        this.pushWithReply(refGenerator, "event", {
          type: "form",
          event: phxEvent,
          value: formData,
          meta,
          cid
        }).then((result) => {
          if (result.type === "ok") {
            onReply(result.resp);
          } else {
            this.logError(
              "event.submit-push-failed",
              "Failed to push form submit",
              {
                error: result.error,
                phxEvent,
                formEl
              },
              result.context
            );
          }
        });
      }
    }
    uploadFiles(formEl, phxEvent, targetCtx, ref, cid, onComplete) {
      const joinCountAtUpload = this.joinCount;
      const inputEls = LiveUploader.activeFileInputs(formEl);
      let numFileInputsInProgress = inputEls.length;
      inputEls.forEach((inputEl) => {
        const uploader = new LiveUploader(inputEl, this, () => {
          this.activeUploaders.delete(uploader);
          numFileInputsInProgress--;
          if (numFileInputsInProgress === 0) {
            onComplete();
          }
        });
        this.activeUploaders.add(uploader);
        const entries = uploader.entries().map((entry) => entry.toPreflightPayload());
        if (entries.length === 0) {
          this.activeUploaders.delete(uploader);
          numFileInputsInProgress--;
          return;
        }
        const payload = {
          ref: inputEl.getAttribute(PHX_UPLOAD_REF),
          entries,
          cid: this.targetComponentID(inputEl.form, targetCtx)
        };
        this.log("upload", () => ["sending preflight request", payload], {
          code: "upload.preflight-request",
          metadata: () => ({ payload })
        });
        this.pushWithReply(null, "allow_upload", payload).then((result) => {
          if (result.type === "ok") {
            this.log("upload", () => ["got preflight response", result.resp], {
              code: "upload.preflight-response",
              metadata: () => ({ response: result.resp })
            });
            uploader.entries().forEach((entry) => {
              if (result.resp.entries && !result.resp.entries[entry.ref]) {
                this.handleFailedEntryPreflight(
                  entry.ref,
                  "failed preflight",
                  uploader
                );
              }
            });
            if (result.resp.error || Object.keys(result.resp.entries).length === 0) {
              this.undoRefs(ref, phxEvent);
              const errors = result.resp.error || [];
              errors.map(([entry_ref, reason]) => {
                this.handleFailedEntryPreflight(entry_ref, reason, uploader);
              });
              this.activeUploaders.delete(uploader);
            } else {
              const onError = (callback) => {
                this.channel.onError(() => {
                  if (this.joinCount === joinCountAtUpload) {
                    callback();
                  }
                });
              };
              uploader.initAdapterUpload(result.resp, onError, this.liveSocket);
            }
          } else {
            this.activeUploaders.delete(uploader);
            this.logError(
              "upload.push-failed",
              "Failed to push upload",
              {
                error: result.error,
                phxEvent,
                formEl
              },
              result.context
            );
          }
        });
      });
    }
    handleFailedEntryPreflight(uploadRef, reason, uploader) {
      if (uploader.isAutoUpload()) {
        const entry = uploader.entries().find((entry2) => entry2.ref === uploadRef.toString());
        if (entry) {
          entry.cancel();
        }
      } else {
        uploader.entries().map((entry) => entry.cancel());
      }
      this.log("upload", () => [`error for entry ${uploadRef}`, reason], {
        code: "upload.preflight-rejected",
        metadata: () => ({ uploadRef, reason })
      });
    }
    dispatchUploads(targetCtx, name, filesOrBlobs) {
      const targetElement = this.targetCtxElement(targetCtx) || this.el;
      const inputs = dom_default.findUploadInputs(targetElement).filter(
        (el) => el.name === name
      );
      if (inputs.length === 0) {
        this.logError(
          "upload.input-not-found",
          `no live file inputs found matching the name "${name}"`,
          { name },
          { attribution: "app" }
        );
      } else if (inputs.length > 1) {
        this.logError(
          "upload.duplicate-input",
          `duplicate live file inputs found matching the name "${name}"`,
          { name, inputs },
          { attribution: "app" }
        );
      } else {
        dom_default.dispatchEvent(inputs[0], PHX_TRACK_UPLOADS, {
          detail: { files: filesOrBlobs }
        });
      }
    }
    targetCtxElement(targetCtx) {
      if (isCid(targetCtx)) {
        const target = dom_default.findComponent(this.id, targetCtx);
        return target;
      } else if (targetCtx) {
        return targetCtx;
      } else {
        return null;
      }
    }
    pushFormRecovery(oldForm, newForm, templateDom, callback) {
      const phxChange = this.binding("change");
      const phxTarget = newForm.getAttribute(this.binding("target")) || newForm;
      const phxEvent = newForm.getAttribute(this.binding(PHX_AUTO_RECOVER)) || newForm.getAttribute(this.binding("change"));
      const inputs = Array.from(oldForm.elements).filter(
        (el) => dom_default.isFormAssociated(el) && el.name && !el.hasAttribute(phxChange)
      );
      if (inputs.length === 0) {
        callback();
        return;
      }
      inputs.forEach(
        (input2) => input2.hasAttribute(PHX_UPLOAD_REF) && LiveUploader.clearFiles(input2)
      );
      const input = inputs.find((el) => el.type !== "hidden") || inputs[0];
      let pending = 0;
      this.withinTargets(
        phxTarget,
        (targetView, targetCtx) => {
          const cid = this.targetComponentID(newForm, targetCtx);
          pending++;
          let e2 = new CustomEvent("phx:form-recovery", {
            detail: { sourceElement: oldForm }
          });
          js_default.exec(e2, "change", phxEvent, this, input, [
            "push",
            {
              _target: input.name,
              targetView,
              targetCtx,
              newCid: cid,
              callback: () => {
                pending--;
                if (pending === 0) {
                  callback();
                }
              }
            }
          ]);
        },
        templateDom
      );
    }
    pushLinkPatch(e2, href, targetEl, callback) {
      const linkRef = this.liveSocket.setPendingLink(href);
      const loading = e2.isTrusted && e2.type !== "popstate";
      const refGen = targetEl ? () => this.putRef(
        [{ el: targetEl, loading, lock: true }],
        null,
        "click"
      ) : null;
      const fallback = () => this.liveSocket.redirect(window.location.href, null, null);
      const url = href.startsWith("/") ? `${location.protocol}//${location.host}${href}` : href;
      this.pushWithReply(refGen, "live_patch", { url }).then((result) => {
        if (result.type === "ok") {
          this.liveSocket.requestDOMUpdate(() => {
            if (result.resp.link_redirect) {
              this.liveSocket.replaceMain(href, null, callback, linkRef);
            } else if (result.resp.redirect) {
              return;
            } else {
              if (this.liveSocket.commitPendingLink(linkRef)) {
                this.href = href;
              }
              this.applyPendingUpdates();
              callback && callback(linkRef);
            }
          });
        } else {
          fallback();
        }
      });
    }
    getFormsForRecovery() {
      if (this.joinCount === 0) {
        return {};
      }
      const phxChange = this.binding("change");
      return dom_default.all(
        document,
        `#${CSS.escape(this.id)} form[${phxChange}], [${PHX_TELEPORTED_REF}="${CSS.escape(this.id)}"] form[${phxChange}]`
      ).filter((form) => form instanceof HTMLFormElement).filter((form) => form.id).filter((form) => form.elements.length > 0).filter(
        (form) => form.getAttribute(this.binding(PHX_AUTO_RECOVER)) !== "ignore"
      ).map((form) => {
        const clonedForm = form.cloneNode(true);
        index_default(clonedForm, form, {
          onBeforeElUpdated: (fromEl, toEl) => {
            dom_default.copyPrivates(fromEl, toEl);
            if (fromEl.getAttribute("form") === form.id && fromEl.parentNode) {
              fromEl.parentNode.removeChild(fromEl);
              return false;
            }
            return true;
          }
        });
        const externalElements = document.querySelectorAll(
          `[form="${CSS.escape(form.id)}"]`
        );
        Array.from(externalElements).forEach((el) => {
          const clonedEl = el.cloneNode(true);
          index_default(clonedEl, el);
          dom_default.copyPrivates(clonedEl, el);
          clonedEl.removeAttribute("form");
          clonedForm.appendChild(clonedEl);
        });
        return clonedForm;
      }).reduce((acc, form) => {
        acc[form.id] = form;
        return acc;
      }, {});
    }
    maybePushComponentsDestroyed(destroyedCIDs) {
      let willDestroyCIDs = destroyedCIDs.filter((cid) => {
        return dom_default.findComponent(this.id, cid) === null;
      });
      const onError = (result, cids) => {
        if (!this.isDestroyed()) {
          this.logError(
            "component.destroy-push-failed",
            "Failed to push components destroyed",
            { error: result.error, cids },
            result.context
          );
        }
      };
      if (willDestroyCIDs.length > 0) {
        willDestroyCIDs.forEach((cid) => this.rendered.resetRender(cid));
        this.pushWithReply(null, "cids_will_destroy", {
          cids: willDestroyCIDs
        }).then((result) => {
          if (result.type === "ok") {
            this.liveSocket.requestDOMUpdate(() => {
              let completelyDestroyCIDs = willDestroyCIDs.filter((cid) => {
                return dom_default.findComponent(this.id, cid) === null;
              });
              if (completelyDestroyCIDs.length > 0) {
                this.pushWithReply(null, "cids_destroyed", {
                  cids: completelyDestroyCIDs
                }).then((result2) => {
                  if (result2.type === "ok") {
                    this.rendered.pruneCIDs(result2.resp.cids);
                  } else {
                    onError(result2, completelyDestroyCIDs);
                  }
                });
              }
            });
          } else {
            onError(result, willDestroyCIDs);
          }
        });
      }
    }
    ownsElement(el) {
      let parentViewEl = dom_default.closestViewEl(el);
      return el.getAttribute(PHX_PARENT_ID) === this.id || parentViewEl && parentViewEl.id === this.id || !parentViewEl && this.isDead;
    }
    submitForm(form, targetCtx, phxEvent, submitter, opts = {}) {
      dom_default.putPrivate(form, PHX_HAS_SUBMITTED, true);
      const inputs = Array.from(form.elements);
      inputs.forEach((input) => dom_default.putPrivate(input, PHX_HAS_SUBMITTED, true));
      this.liveSocket.blurActiveElement();
      this.pushFormSubmit(form, targetCtx, phxEvent, submitter, opts, () => {
        this.liveSocket.restorePreviouslyActiveFocus();
      });
    }
    binding(kind) {
      return this.liveSocket.binding(kind);
    }
    // phx-portal
    pushPortalElementId(id) {
      this.portalElementIds.add(id);
    }
    dropPortalElementId(id) {
      this.portalElementIds.delete(id);
    }
    destroyPortalElements() {
      if (!this.liveSocket.unloaded) {
        this.portalElementIds.forEach((id) => {
          const el = document.getElementById(id);
          if (el) {
            el.remove();
          }
        });
      }
    }
  };
  var BUFFERS = Object.freeze({ RenderingBuffer, ReportingBuffer });
  var LiveSocket = class {
    /**
     * Creates a new LiveSocket instance.
     */
    constructor(url, phxSocket, opts = {}) {
      var _a;
      this.unloaded = false;
      this.buffers = BUFFERS;
      if (!phxSocket || phxSocket.constructor.name === "Object") {
        throw new Error(`
      a phoenix Socket must be provided as the second argument to the LiveSocket constructor. For example:

          import {Socket} from "phoenix"
          import {LiveSocket} from "phoenix_live_view"
          let liveSocket = new LiveSocket("/live", Socket, {...})
      `);
      }
      this.socket = new phxSocket(url, opts);
      this.bindingPrefix = opts.bindingPrefix || BINDING_PREFIX;
      this.params = closure(opts.params || {});
      this.viewLogger = opts.viewLogger;
      this.metadataCallbacks = opts.metadata || {};
      this.defaults = Object.assign(clone(DEFAULTS), opts.defaults || {});
      this.prevActive = null;
      this.silenced = false;
      this.main = null;
      this.outgoingMainEl = null;
      this.clickStartedAtTarget = null;
      this.linkRef = 1;
      this.roots = {};
      this.href = window.location.href;
      this.pendingLink = null;
      this.currentLocation = clone(window.location);
      this.hooks = opts.hooks || {};
      this.uploaders = opts.uploaders || {};
      this.RenderingBuffer = RenderingBuffer;
      this.loaderTimeout = opts.loaderTimeout || LOADER_TIMEOUT;
      this.disconnectedTimeout = opts.disconnectedTimeout || DISCONNECTED_TIMEOUT;
      this.reloadWithJitterTimer = null;
      this.maxReloads = opts.maxReloads || MAX_RELOADS;
      this.reloadJitterMin = opts.reloadJitterMin || RELOAD_JITTER_MIN;
      this.reloadJitterMax = opts.reloadJitterMax || RELOAD_JITTER_MAX;
      this.failsafeJitter = opts.failsafeJitter || FAILSAFE_JITTER;
      this.localStorage = opts.localStorage || window.localStorage;
      this.sessionStorage = opts.sessionStorage || window.sessionStorage;
      this.boundTopLevelEvents = false;
      this.boundEventNames = /* @__PURE__ */ new Set();
      this.blockPhxChangeWhileComposing = opts.blockPhxChangeWhileComposing || false;
      this.cascadePhxRemoveOnNavigation = (_a = opts.cascadePhxRemoveOnNavigation) != null ? _a : true;
      this.serverCloseRef = null;
      this.domCallbacks = Object.assign(
        {
          jsQuerySelectorAll: null,
          onPatchStart: closure(),
          onPatchEnd: closure(),
          onNodeAdded: closure(),
          onBeforeElUpdated: closure()
        },
        opts.dom || {}
      );
      this.transitions = new TransitionSet();
      this.currentHistoryPosition = parseInt(this.sessionStorage.getItem(PHX_LV_HISTORY_POSITION) || "0") || 0;
      window.addEventListener("pagehide", (_e2) => {
        this.unloaded = true;
      });
      this.socket.onOpen(() => {
        if (this.isUnloaded()) {
          window.location.reload();
        }
      });
    }
    // public
    /**
     * Returns the version of the LiveView client.
     */
    version() {
      return "1.2.12";
    }
    /**
     * Returns true if profiling is enabled. See {@link enableProfiling} and {@link disableProfiling}.
     */
    isProfileEnabled() {
      return this.sessionStorage.getItem(PHX_LV_PROFILE) === "true";
    }
    /**
     * Installs a rendered buffer: what the renderer writes rendered HTML through.
     *
     * A buffer can observe or annotate the output — for example to mark which
     * HEEx function components re-rendered, for a debugging overlay. See
     * {@link RenderingBuffer} for the protocol a buffer implements.
     *
     * It applies to views that are already mounted as well as to views that join
     * later, and nothing is re-rendered to install it: it sees each part of the
     * page the next time a patch renders that part, so a buffer that annotates
     * the output leaves whatever is already in the DOM untouched until then.
     *
     *     const previous = liveSocket.attachDebugBuffer(MyBuffer)
     *
     * @param bufferClass - a class extending {@link RenderingBuffer}.
     * @returns The class installed until now, to restore it with.
     *
     * @internal
     */
    attachDebugBuffer(bufferClass) {
      const current = this.RenderingBuffer;
      this.RenderingBuffer = bufferClass;
      return current;
    }
    /**
     * Returns true if debugging is enabled. See {@link enableDebug} and {@link disableDebug}.
     */
    isDebugEnabled() {
      return this.sessionStorage.getItem(PHX_LV_DEBUG) === "true";
    }
    /**
     * Returns true if debugging is disabled. See {@link enableDebug} and {@link disableDebug}.
     */
    isDebugDisabled() {
      return this.sessionStorage.getItem(PHX_LV_DEBUG) === "false";
    }
    /**
     * Enables debugging.
     *
     * When debugging is enabled, the LiveView client will log debug information to the console.
     * See [Debugging client events](https://phoenix-live-view.hexdocs.pm/js-interop.html#debugging-client-events) for more information.
     */
    enableDebug() {
      this.sessionStorage.setItem(PHX_LV_DEBUG, "true");
    }
    /**
     * Enables profiling.
     *
     * When profiling is enabled, the LiveView client will log profiling information to the console.
     */
    enableProfiling() {
      this.sessionStorage.setItem(PHX_LV_PROFILE, "true");
    }
    /**
     * Disables debugging.
     */
    disableDebug() {
      this.sessionStorage.setItem(PHX_LV_DEBUG, "false");
    }
    /**
     * Disables profiling.
     */
    disableProfiling() {
      this.sessionStorage.removeItem(PHX_LV_PROFILE);
    }
    /**
     * Enables latency simulation.
     *
     * When latency simulation is enabled, the LiveView client will add a delay to requests and responses from the server.
     * See [Simulating Latency](https://phoenix-live-view.hexdocs.pm/js-interop.html#simulating-latency) for more information.
     */
    enableLatencySim(upperBoundMs) {
      this.enableDebug();
      console.log(
        "latency simulator enabled for the duration of this browser session. Call disableLatencySim() to disable"
      );
      this.sessionStorage.setItem(PHX_LV_LATENCY_SIM, upperBoundMs.toString());
    }
    /**
     * Disables latency simulation.
     */
    disableLatencySim() {
      this.sessionStorage.removeItem(PHX_LV_LATENCY_SIM);
    }
    /**
     * Returns the current latency simulation upper bound.
     */
    getLatencySim() {
      const str = this.sessionStorage.getItem(PHX_LV_LATENCY_SIM);
      return str ? parseInt(str) : null;
    }
    /**
     * Returns the Phoenix Socket instance.
     */
    getSocket() {
      return this.socket;
    }
    /**
     * Connects to the LiveView server.
     */
    connect() {
      const host = window.location.hostname.toLowerCase();
      if ((host === "localhost" || host.endsWith(".localhost")) && !this.isDebugDisabled()) {
        this.enableDebug();
      }
      const doConnect = () => {
        this.resetReloadStatus();
        if (this.joinRootViews()) {
          this.bindTopLevelEvents();
          this.socket.connect();
        } else if (this.main) {
          this.socket.connect();
        } else {
          this.bindTopLevelEvents({ dead: true });
        }
        this.joinDeadView();
      };
      if (["complete", "loaded", "interactive"].indexOf(document.readyState) >= 0) {
        doConnect();
      } else {
        document.addEventListener("DOMContentLoaded", () => doConnect());
      }
    }
    /**
     * Disconnects from the LiveView server.
     */
    disconnect(callback) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      if (this.serverCloseRef) {
        this.socket.off([this.serverCloseRef]);
        this.serverCloseRef = null;
      }
      this.socket.disconnect(callback);
    }
    /**
     * Can be used to replace the transport used by the underlying Phoenix Socket.
     */
    replaceTransport(transport) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      this.socket.replaceTransport(transport);
      this.connect();
    }
    /**
     * Executes an encoded JS command, targeting the given element.
     *
     * See [`Phoenix.LiveView.JS`](https://phoenix-live-view.hexdocs.pm/Phoenix.LiveView.JS.html) for more information.
     */
    execJS(el, encodedJS, eventType = null) {
      const e2 = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
      this.owner(el, (view) => js_default.exec(e2, eventType, encodedJS, view, el));
    }
    /**
     * Returns an object with methods to manipulate the DOM and execute JavaScript.
     * The applied changes integrate with server DOM patching.
     *
     * See [JavaScript interoperability](https://phoenix-live-view.hexdocs.pm/js-interop.html) for more information.
     */
    js() {
      return js_commands_default(this, "js");
    }
    // private
    /** @internal */
    unload() {
      if (this.unloaded) {
        return;
      }
      if (this.main && this.isConnected()) {
        this.log(this.main, "socket", () => ["disconnect for page nav"], {
          code: "socket.page-navigation-disconnect"
        });
      }
      this.unloaded = true;
      this.destroyAllViews();
      this.disconnect();
    }
    /** @internal */
    triggerDOM(kind, args) {
      this.domCallbacks[kind](...args);
    }
    /** @internal */
    time(name, func) {
      if (!this.isProfileEnabled() || !console.time) {
        return func();
      }
      console.time(name);
      const result = func();
      console.timeEnd(name);
      return result;
    }
    /** @internal */
    log(view, kind, msgCallback, diagnostic) {
      var _a, _b;
      const debugEnabled = this.isDebugEnabled();
      const level = (_a = diagnostic == null ? void 0 : diagnostic.level) != null ? _a : "debug";
      const emitDiagnostic = !!diagnostic && (level !== "debug" || debugEnabled);
      if (!this.viewLogger && !debugEnabled && !emitDiagnostic) {
        return;
      }
      const [message, obj] = msgCallback();
      if (this.viewLogger) {
        this.viewLogger(view, kind, message, obj);
      } else if (debugEnabled) {
        debug(view, kind, message, obj);
      }
      if (emitDiagnostic && diagnostic) {
        dispatchDiagnostic(__spreadValues({
          level,
          code: diagnostic.code,
          message,
          viewId: view.id,
          metadata: (_b = diagnostic.metadata) == null ? void 0 : _b.call(diagnostic)
        }, diagnostic.context || { attribution: "unknown" }));
      }
    }
    /** @internal */
    requestDOMUpdate(callback) {
      this.transitions.after(callback);
    }
    /** @internal */
    asyncTransition(promise) {
      this.transitions.addAsyncTransition(promise);
    }
    /** @internal */
    transition(time, onStart, onDone = function() {
    }) {
      this.transitions.addTransition(time, onStart, onDone);
    }
    /** @internal */
    onChannel(channel, event, cb) {
      channel.on(event, (data) => {
        const latency = this.getLatencySim();
        if (!latency) {
          cb(data);
        } else {
          setTimeout(() => cb(data), latency);
        }
      });
    }
    /** @internal */
    reloadWithJitter(view, log) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      this.disconnect();
      const minMs = this.reloadJitterMin;
      const maxMs = this.reloadJitterMax;
      let afterMs = Math.floor(Math.random() * (maxMs - minMs + 1)) + minMs;
      const tries = browser_default.updateLocal(
        this.localStorage,
        window.location.pathname,
        CONSECUTIVE_RELOADS,
        0,
        (count) => count + 1
      );
      if (tries >= this.maxReloads) {
        afterMs = this.failsafeJitter;
      }
      this.reloadWithJitterTimer = setTimeout(() => {
        if (view.isDestroyed() || view.isConnected()) {
          return;
        }
        view.destroy();
        log ? log() : this.log(
          view,
          "join",
          () => [`encountered ${tries} consecutive reloads`],
          {
            code: "view.reload-attempts",
            metadata: () => ({ tries })
          }
        );
        if (tries >= this.maxReloads) {
          this.log(
            view,
            "join",
            () => [
              `exceeded ${this.maxReloads} consecutive reloads. Entering failsafe mode`
            ],
            {
              code: "view.reload-failsafe",
              level: "error",
              metadata: () => ({ tries, maxReloads: this.maxReloads })
            }
          );
        }
        if (this.pendingLink !== null) {
          window.location.href = this.pendingLink;
        } else {
          window.location.reload();
        }
      }, afterMs);
    }
    /** @internal */
    getHookDefinition(name) {
      if (!name) {
        return;
      }
      return this.maybeInternalHook(name) || this.hooks[name] || this.maybeRuntimeHook(name);
    }
    /** @internal */
    maybeInternalHook(name) {
      return name && name.startsWith("Phoenix.") && hooks_default[name.split(".")[1]];
    }
    /** @internal */
    maybeRuntimeHook(name) {
      const runtimeHook = document.querySelector(
        `script[${PHX_RUNTIME_HOOK}="${CSS.escape(name)}"]`
      );
      if (!runtimeHook) {
        return;
      }
      let callbacks = window[`phx_hook_${name}`];
      if (!callbacks || typeof callbacks !== "function") {
        logError(
          "hook.runtime-not-function",
          "a runtime hook must be a function",
          {
            runtimeHook,
            name
          },
          { attribution: "app" }
        );
        return;
      }
      const hookDefiniton = callbacks();
      if (hookDefiniton && (typeof hookDefiniton === "object" || typeof hookDefiniton === "function")) {
        return hookDefiniton;
      }
      logError(
        "hook.runtime-invalid-return",
        "runtime hook must return an object with hook callbacks or an instance of ViewHook",
        { runtimeHook, name },
        { attribution: "app" }
      );
    }
    /** @internal */
    isUnloaded() {
      return this.unloaded;
    }
    /** @internal */
    isConnected() {
      return this.socket.isConnected();
    }
    /** @internal */
    getBindingPrefix() {
      return this.bindingPrefix;
    }
    /** @internal */
    binding(kind) {
      return `${this.getBindingPrefix()}${kind}`;
    }
    /** @internal */
    channel(topic, params) {
      return this.socket.channel(topic, params);
    }
    /** @internal */
    joinDeadView() {
      const body = document.body;
      if (body && !this.isPhxView(body) && !this.isPhxView(document.firstElementChild)) {
        const view = this.newRootView(body);
        view.setHref(this.getHref());
        view.joinDead();
        if (!this.main) {
          this.main = view;
        }
        window.requestAnimationFrame(() => {
          var _a;
          view.execNewMounted();
          this.maybeScroll((_a = history.state) == null ? void 0 : _a.scroll);
        });
      }
    }
    /** @internal */
    joinRootViews() {
      let rootsFound = false;
      dom_default.all(
        document,
        `${PHX_VIEW_SELECTOR}:not([${PHX_PARENT_ID}])`,
        (rootEl) => {
          if (!this.getRootById(rootEl.id)) {
            const view = this.newRootView(rootEl);
            if (!dom_default.isPhxSticky(rootEl)) {
              view.setHref(this.getHref());
            }
            view.join();
            if (rootEl.hasAttribute(PHX_MAIN)) {
              this.main = view;
            }
          }
          rootsFound = true;
        }
      );
      return rootsFound;
    }
    /** @internal */
    redirect(to, flash, reloadToken) {
      if (reloadToken) {
        browser_default.setCookie(PHX_RELOAD_STATUS, reloadToken, 60);
      }
      this.unload();
      browser_default.redirect(to, flash);
    }
    /** @internal */
    replaceMain(href, flash, callback = null, linkRef = this.setPendingLink(href)) {
      if (!this.main) {
        return;
      }
      const liveReferer = this.currentLocation.href;
      this.outgoingMainEl = this.outgoingMainEl || this.main.el;
      const stickies = dom_default.findPhxSticky(document) || [];
      const removeEls = this.phxRemoveElementsForNavigation(
        this.outgoingMainEl,
        stickies
      );
      const newMainEl = dom_default.cloneNode(this.outgoingMainEl, "");
      const oldMainView = this.main;
      oldMainView.showLoader(this.loaderTimeout);
      oldMainView.destroy();
      this.main = this.newRootView(newMainEl, flash, liveReferer);
      this.main.setRedirect(href);
      this.transitionRemoves(removeEls, oldMainView);
      this.main.join((joinCount, onDone) => {
        if (joinCount === 1 && this.commitPendingLink(linkRef)) {
          this.requestDOMUpdate(() => {
            removeEls.forEach((el) => {
              if (!el.isSameNode(this.outgoingMainEl)) {
                el.remove();
              }
            });
            stickies.forEach((el) => newMainEl.appendChild(el));
            this.outgoingMainEl.replaceWith(newMainEl);
            this.outgoingMainEl = null;
            callback && callback(linkRef);
            onDone();
          });
        }
      });
    }
    phxRemoveElementsForNavigation(mainEl, stickies = dom_default.findPhxSticky(document) || []) {
      const removeSelector = `[${this.binding("remove")}]`;
      const removeEls = this.cascadePhxRemoveOnNavigation ? [mainEl, ...dom_default.all(mainEl, removeSelector)] : [mainEl];
      return removeEls.filter(
        (el) => el.matches(removeSelector) && !dom_default.isChildOfAny(el, stickies)
      );
    }
    /** @internal */
    transitionRemoves(elements, view, callback) {
      const removeAttr = this.binding("remove");
      const silenceEvents = (e2) => {
        e2.preventDefault();
        e2.stopImmediatePropagation();
      };
      elements.forEach((el) => {
        for (const event of this.boundEventNames) {
          el.addEventListener(event, silenceEvents, true);
        }
        const e2 = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
        js_default.exec(e2, "remove", el.getAttribute(removeAttr), view, el);
      });
      this.requestDOMUpdate(() => {
        elements.forEach((el) => {
          for (const event of this.boundEventNames) {
            el.removeEventListener(event, silenceEvents, true);
          }
        });
        callback && callback();
      });
    }
    /** @internal */
    isPhxView(el) {
      return el.getAttribute && el.getAttribute(PHX_SESSION) !== null;
    }
    /** @internal */
    newRootView(el, flash, liveReferer) {
      const view = new View(el, this, null, flash, liveReferer);
      this.roots[view.id] = view;
      return view;
    }
    /** @internal */
    owner(childEl, callback) {
      let view;
      const viewEl = dom_default.closestViewEl(childEl);
      if (viewEl) {
        view = dom_default.private(viewEl, "view");
      } else {
        if (!childEl.isConnected) {
          return null;
        }
        view = this.main;
      }
      return view && callback ? callback(view) : view;
    }
    /** @internal */
    withinOwners(childEl, callback) {
      this.owner(childEl, (view) => callback(view, childEl));
    }
    /** @internal */
    getViewByEl(el) {
      const rootId = el.getAttribute(PHX_ROOT_ID);
      return maybe(
        this.getRootById(rootId),
        (root) => root.getDescendentByEl(el)
      );
    }
    /** @internal */
    getRootById(id) {
      return this.roots[id];
    }
    /** @internal */
    destroyAllViews() {
      for (const id in this.roots) {
        this.roots[id].destroy();
        delete this.roots[id];
      }
      this.main = null;
    }
    /** @internal */
    destroyViewByEl(el) {
      const root = this.getRootById(el.getAttribute(PHX_ROOT_ID));
      if (root && root.id === el.id) {
        root.destroy();
        delete this.roots[root.id];
      } else if (root) {
        root.destroyDescendent(el.id);
      }
    }
    /** @internal */
    getActiveElement() {
      return document.activeElement;
    }
    /** @internal */
    dropActiveElement(view) {
      if (this.prevActive && view.ownsElement(this.prevActive)) {
        this.prevActive = null;
      }
    }
    /** @internal */
    restorePreviouslyActiveFocus() {
      if (this.prevActive && this.prevActive !== document.body && this.prevActive instanceof HTMLElement) {
        this.prevActive.focus();
      }
    }
    /** @internal */
    blurActiveElement() {
      this.prevActive = this.getActiveElement();
      if (this.prevActive !== document.body && this.prevActive instanceof HTMLElement) {
        this.prevActive.blur();
      }
    }
    /** @internal */
    bindTopLevelEvents({ dead } = {}) {
      if (this.serverCloseRef === null) {
        this.serverCloseRef = this.socket.onClose((event) => {
          if (event && event.code === 1e3 && this.main) {
            return this.reloadWithJitter(this.main);
          }
        });
      }
      if (this.boundTopLevelEvents) {
        return;
      }
      this.boundTopLevelEvents = true;
      document.body.addEventListener("click", function() {
      });
      window.addEventListener(
        "pageshow",
        (e2) => {
          if (e2.persisted) {
            this.getSocket().disconnect();
            this.withPageLoading({ to: window.location.href, kind: "redirect" });
            window.location.reload();
          }
        },
        true
      );
      if (!dead) {
        this.bindNav();
      }
      this.bindClicks();
      if (!dead) {
        this.bindForms();
      }
      this.bind(
        { keyup: "keyup", keydown: "keydown" },
        (e2, type, view, targetEl, phxEvent, _phxTarget) => {
          const matchKey = targetEl.getAttribute(this.binding(PHX_KEY));
          const pressedKey = e2.key && e2.key.toLowerCase();
          if (matchKey && matchKey.toLowerCase() !== pressedKey) {
            return;
          }
          const data = __spreadValues({ key: e2.key }, this.eventMeta(type, e2, targetEl));
          js_default.exec(e2, type, phxEvent, view, targetEl, ["push", { data }]);
        }
      );
      this.bind(
        { blur: "focusout", focus: "focusin" },
        (e2, type, view, targetEl, phxEvent, phxTarget) => {
          if (!phxTarget) {
            const data = __spreadValues({}, this.eventMeta(type, e2, targetEl));
            js_default.exec(e2, type, phxEvent, view, targetEl, ["push", { data }]);
          }
        }
      );
      this.bind(
        { blur: "blur", focus: "focus" },
        (e2, type, view, targetEl, phxEvent, phxTarget) => {
          if (phxTarget === "window") {
            const data = this.eventMeta(type, e2, targetEl);
            js_default.exec(e2, type, phxEvent, view, targetEl, ["push", { data }]);
          }
        }
      );
      this.on("dragover", (e2) => e2.preventDefault());
      const dropTargetDragDepths = /* @__PURE__ */ new WeakMap();
      this.on("dragenter", (e2) => {
        let target = e2.target && dom_default.elementFromTarget(e2.target);
        if (!target) {
          return;
        }
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        if (eventContainsFiles(e2)) {
          const dragDepth = (dropTargetDragDepths.get(dropzone) || 0) + 1;
          dropTargetDragDepths.set(dropzone, dragDepth);
          if (dragDepth === 1) {
            this.js().addClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
          }
        }
      });
      this.on("dragleave", (e2) => {
        let target = e2.target && dom_default.elementFromTarget(e2.target);
        if (!target) {
          return;
        }
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        const dragDepth = dropTargetDragDepths.get(dropzone);
        if (dragDepth === void 0) {
          return;
        } else if (dragDepth > 1) {
          dropTargetDragDepths.set(dropzone, dragDepth - 1);
        } else {
          dropTargetDragDepths.delete(dropzone);
          this.js().removeClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
        }
      });
      this.on("drop", (e2) => {
        let target = e2.target && dom_default.elementFromTarget(e2.target);
        if (!target) {
          return;
        }
        e2.preventDefault();
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        dropTargetDragDepths.delete(dropzone);
        this.js().removeClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
        if (!e2.dataTransfer) {
          return;
        }
        const dropTargetId = dropzone.getAttribute(this.binding(PHX_DROP_TARGET));
        const dropTarget = dropTargetId && document.getElementById(dropTargetId);
        const files = Array.from(e2.dataTransfer.files || []);
        if (!dropTarget || !(dropTarget instanceof HTMLInputElement) || dropTarget.disabled || files.length === 0 || !(dropTarget.files instanceof FileList)) {
          return;
        }
        LiveUploader.trackFiles(dropTarget, files, e2.dataTransfer);
        dropTarget.dispatchEvent(new Event("input", { bubbles: true }));
      });
      this.on(PHX_TRACK_UPLOADS, (e2) => {
        const uploadTarget = e2.target && dom_default.elementFromTarget(e2.target);
        if (!dom_default.isUploadInput(uploadTarget)) {
          return;
        }
        const files = Array.from(e2.detail.files || []).filter(
          (f2) => f2 instanceof File || f2 instanceof Blob
        );
        LiveUploader.trackFiles(uploadTarget, files);
        uploadTarget.dispatchEvent(new Event("input", { bubbles: true }));
      });
    }
    /** @internal */
    eventMeta(eventName, e2, targetEl) {
      const callback = this.metadataCallbacks[eventName];
      return callback ? callback(e2, targetEl) : {};
    }
    /** @internal */
    setPendingLink(href) {
      this.linkRef++;
      this.pendingLink = href;
      this.resetReloadStatus();
      return this.linkRef;
    }
    /**
     * @internal
     * anytime we are navigating or connecting, drop reload cookie in case
     * we issue the cookie but the next request was interrupted and the server never dropped it
     */
    resetReloadStatus() {
      browser_default.deleteCookie(PHX_RELOAD_STATUS);
    }
    /** @internal */
    commitPendingLink(linkRef) {
      if (this.linkRef !== linkRef) {
        return false;
      }
      if (this.pendingLink !== null) {
        this.href = this.pendingLink;
        this.pendingLink = null;
      }
      return true;
    }
    /** @internal */
    getHref() {
      return this.href;
    }
    /** @internal */
    hasPendingLink() {
      return !!this.pendingLink;
    }
    /** @internal */
    bind(events, callback) {
      for (const event in events) {
        const browserEventName = events[event];
        this.on(browserEventName, (e2) => {
          const binding = this.binding(event);
          const windowBinding = this.binding(`window-${event}`);
          const targetPhxEvent = e2.target instanceof Element && e2.target.getAttribute(binding);
          if (!(e2.target instanceof Element)) {
            return;
          }
          if (targetPhxEvent) {
            this.debounce(e2.target, e2, browserEventName, () => {
              this.withinOwners(e2.target, (view) => {
                callback(
                  e2,
                  event,
                  view,
                  e2.target,
                  targetPhxEvent,
                  null
                );
              });
            });
          } else {
            dom_default.all(document, `[${windowBinding}]`, (el) => {
              const phxEvent = el.getAttribute(windowBinding);
              this.debounce(el, e2, browserEventName, () => {
                this.withinOwners(el, (view) => {
                  callback(
                    e2,
                    event,
                    view,
                    el,
                    phxEvent,
                    "window"
                  );
                });
              });
            });
          }
        });
      }
    }
    /** @internal */
    bindClicks() {
      this.on("mousedown", (e2) => this.clickStartedAtTarget = e2.target);
      this.bindClick();
    }
    /** @internal */
    bindClick() {
      const click = this.binding("click");
      window.addEventListener(
        "click",
        (e2) => {
          let target = e2.target && dom_default.elementFromTarget(e2.target);
          if (!target) {
            return;
          }
          if (e2.detail === 0)
            this.clickStartedAtTarget = target;
          const clickStartedAtTarget = this.clickStartedAtTarget || target;
          target = closestPhxBinding(target, click);
          this.dispatchClickAway(e2, clickStartedAtTarget);
          this.clickStartedAtTarget = null;
          if (!target) {
            return;
          }
          const phxEvent = target.getAttribute(click);
          if (!phxEvent) {
            if (dom_default.isNewPageClick(e2, window.location)) {
              this.unload();
            }
            return;
          }
          if (target.getAttribute("href") === "#") {
            e2.preventDefault();
          }
          if (target.hasAttribute(PHX_REF_SRC)) {
            return;
          }
          this.debounce(target, e2, "click", () => {
            this.withinOwners(target, (view) => {
              js_default.exec(e2, "click", phxEvent, view, target, [
                "push",
                { data: this.eventMeta("click", e2, target) }
              ]);
            });
          });
        },
        false
      );
    }
    /** @internal */
    dispatchClickAway(e2, clickStartedAt) {
      const phxClickAway = this.binding("click-away");
      const portal = clickStartedAt.closest(`[${PHX_TELEPORTED_SRC}]`);
      const portalStartedAt = portal && dom_default.byId(portal.getAttribute(PHX_TELEPORTED_SRC));
      dom_default.all(document, `[${phxClickAway}]`, (el) => {
        let startedAt = clickStartedAt;
        if (portal && !portal.contains(el)) {
          startedAt = portalStartedAt;
        }
        if (!(el.isSameNode(startedAt) || el.contains(startedAt) || // When clicking a link with custom method,
        // phoenix_html triggers a click on a submit button
        // of a hidden form appended to the body. For such cases
        // where the clicked target is hidden, we skip click-away.
        //
        // Also, when we have a portal, we don't want to check the visibility
        // of the portal source, as it's a <template> that is always not visible.
        // Instead, check the visibility of the original click target.
        !js_default.isVisible(clickStartedAt))) {
          this.withinOwners(el, (view) => {
            const phxEvent = el.getAttribute(phxClickAway);
            if (js_default.isVisible(el) && js_default.isInViewport(el)) {
              js_default.exec(e2, "click", phxEvent, view, el, [
                "push",
                { data: this.eventMeta("click", e2, e2.target) }
              ]);
            }
          });
        }
      });
    }
    /** @internal */
    bindNav() {
      if (!browser_default.canPushState()) {
        return;
      }
      if (history.scrollRestoration) {
        history.scrollRestoration = "manual";
      }
      let scrollTimer = null;
      window.addEventListener("scroll", (_e2) => {
        scrollTimer != null && clearTimeout(scrollTimer);
        scrollTimer = setTimeout(() => {
          browser_default.updateCurrentState(
            (state) => Object.assign(state, { scroll: window.scrollY })
          );
        }, 100);
      });
      window.addEventListener(
        "popstate",
        (event) => {
          if (!this.isNewLocation(window.location)) {
            return;
          }
          const { type, backType, id, scroll, position } = event.state || {};
          const href = window.location.href;
          const isForward = position > this.currentHistoryPosition;
          const navType = isForward ? type : backType || type;
          const direction = isForward ? "forward" : "backward";
          const detail = {
            href,
            patch: navType === "patch",
            pop: true,
            direction
          };
          if (!this.dispatchBeforeNavigate(detail)) {
            if (isForward) {
              history.back();
            } else {
              history.forward();
            }
            return;
          }
          this.registerNewLocation(window.location);
          this.currentHistoryPosition = position || 0;
          this.sessionStorage.setItem(
            PHX_LV_HISTORY_POSITION,
            this.currentHistoryPosition.toString()
          );
          dom_default.dispatchEvent(window, "phx:navigate", { detail });
          this.requestDOMUpdate(() => {
            const callback = () => {
              this.maybeScroll(scroll);
            };
            if (this.main && this.main.isConnected() && navType === "patch" && id === this.main.id) {
              this.main.pushLinkPatch(event, href, null, callback);
            } else {
              this.replaceMain(href, null, callback);
            }
          });
        },
        false
      );
      window.addEventListener(
        "click",
        (e2) => {
          let el = e2.target && dom_default.elementFromTarget(e2.target);
          if (!el) {
            return;
          }
          const target = closestPhxBinding(
            el,
            PHX_LIVE_LINK
          );
          const type = target && target.getAttribute(PHX_LIVE_LINK);
          if (!type || !this.isConnected() || !this.main || dom_default.wantsNewTab(e2)) {
            return;
          }
          const href = target.href instanceof SVGAnimatedString ? target.href.baseVal : target.href;
          const linkState = target.getAttribute(PHX_LINK_STATE);
          if (linkState !== "replace" && linkState !== "push") {
            throw new Error(
              `expected ${PHX_LINK_STATE} to be "replace" or "push", got: ${linkState}`
            );
          }
          if (type !== "patch" && type !== "redirect") {
            throw new Error(
              `expected ${PHX_LIVE_LINK} to be "patch" or "redirect", got: ${type}`
            );
          }
          e2.preventDefault();
          e2.stopImmediatePropagation();
          if (this.pendingLink === href) {
            return;
          }
          const detail = {
            href,
            patch: type === "patch",
            pop: false,
            direction: "forward"
          };
          const phxClick = target.getAttribute(this.binding("click"));
          const execPhxClick = () => {
            if (phxClick) {
              this.requestDOMUpdate(() => this.execJS(target, phxClick, "click"));
            }
          };
          if (!this.dispatchBeforeNavigate(detail)) {
            execPhxClick();
            return;
          }
          this.requestDOMUpdate(() => {
            if (type === "patch") {
              this.pushHistoryPatch(e2, href, linkState, target);
            } else {
              this.historyRedirect(e2, href, linkState, null, target);
            }
            execPhxClick();
          });
        },
        false
      );
    }
    /** @internal */
    maybeScroll(scroll) {
      if (typeof scroll === "number") {
        requestAnimationFrame(() => {
          window.scrollTo(0, scroll);
        });
      }
    }
    /** @internal */
    dispatchEvent(event, payload = {}) {
      dom_default.dispatchEvent(window, `phx:${event}`, { detail: payload });
    }
    /** @internal */
    dispatchEvents(events) {
      events.forEach(([event, payload]) => this.dispatchEvent(event, payload));
    }
    /** @internal */
    withPageLoading(info, callback) {
      dom_default.dispatchEvent(window, "phx:page-loading-start", { detail: info });
      const done = () => dom_default.dispatchEvent(window, "phx:page-loading-stop", { detail: info });
      return callback ? callback(done) : done;
    }
    /** @internal */
    dispatchBeforeNavigate(detail) {
      return dom_default.dispatchEvent(window, "phx:before-navigate", { detail });
    }
    /** @internal */
    pushHistoryPatch(e2, href, linkState, targetEl) {
      if (!this.isConnected() || !(this.main && this.main.isMain())) {
        return browser_default.redirect(href);
      }
      this.withPageLoading({ to: href, kind: "patch" }, (done) => {
        this.main.pushLinkPatch(e2, href, targetEl, (linkRef) => {
          this.historyPatch(href, linkState, linkRef);
          done();
        });
      });
    }
    /** @internal */
    historyPatch(href, linkState, linkRef = this.setPendingLink(href)) {
      if (!this.commitPendingLink(linkRef)) {
        return;
      }
      this.currentHistoryPosition++;
      this.sessionStorage.setItem(
        PHX_LV_HISTORY_POSITION,
        this.currentHistoryPosition.toString()
      );
      browser_default.updateCurrentState((state) => __spreadProps(__spreadValues({}, state), { backType: "patch" }));
      browser_default.pushState(
        linkState,
        {
          type: "patch",
          id: this.main.id,
          position: this.currentHistoryPosition
        },
        href
      );
      dom_default.dispatchEvent(window, "phx:navigate", {
        detail: { patch: true, href, pop: false, direction: "forward" }
      });
      this.registerNewLocation(window.location);
    }
    /** @internal */
    historyRedirect(e2, href, linkState, flash, targetEl) {
      const clickLoading = targetEl && e2.isTrusted && e2.type !== "popstate";
      if (clickLoading) {
        targetEl.classList.add("phx-click-loading");
      }
      if (!this.isConnected() || !(this.main && this.main.isMain())) {
        return browser_default.redirect(href, flash);
      }
      if (/^\/$|^\/[^\/]+.*$/.test(href)) {
        const { protocol, host } = window.location;
        href = `${protocol}//${host}${href}`;
      }
      const scroll = window.scrollY;
      this.withPageLoading({ to: href, kind: "redirect" }, (done) => {
        this.replaceMain(href, flash, (linkRef) => {
          if (linkRef === this.linkRef) {
            this.currentHistoryPosition++;
            this.sessionStorage.setItem(
              PHX_LV_HISTORY_POSITION,
              this.currentHistoryPosition.toString()
            );
            browser_default.updateCurrentState((state) => __spreadProps(__spreadValues({}, state), {
              backType: "redirect"
            }));
            browser_default.pushState(
              linkState,
              {
                type: "redirect",
                id: this.main.id,
                scroll,
                position: this.currentHistoryPosition
              },
              href
            );
            dom_default.dispatchEvent(window, "phx:navigate", {
              detail: { href, patch: false, pop: false, direction: "forward" }
            });
            this.registerNewLocation(window.location);
          }
          if (clickLoading) {
            targetEl.classList.remove("phx-click-loading");
          }
          done();
        });
      });
    }
    /** @internal */
    registerNewLocation(newLocation) {
      if (!this.isNewLocation(newLocation)) {
        return false;
      } else {
        this.currentLocation = clone(newLocation);
        return true;
      }
    }
    /** @internal */
    isNewLocation(newLocation) {
      const { pathname, search } = this.currentLocation;
      if (pathname + search === newLocation.pathname + newLocation.search) {
        return false;
      } else {
        return true;
      }
    }
    /** @internal */
    bindForms() {
      let iterations = 0;
      let externalFormSubmitted = false;
      this.on("submit", (e2) => {
        if (!(e2.target instanceof HTMLFormElement))
          return;
        const phxSubmit = e2.target.getAttribute(this.binding("submit"));
        const phxChange = e2.target.getAttribute(this.binding("change"));
        if (!externalFormSubmitted && phxChange && !phxSubmit) {
          externalFormSubmitted = true;
          e2.preventDefault();
          this.withinOwners(e2.target, (view) => {
            view.disableForm(e2.target, phxChange);
            window.requestAnimationFrame(() => {
              if (dom_default.isUnloadableFormSubmit(e2)) {
                this.unload();
              }
              e2.target.submit();
            });
          });
        }
      });
      this.on("submit", (e2) => {
        if (!(e2.target instanceof HTMLFormElement))
          return;
        const phxEvent = e2.target.getAttribute(this.binding("submit"));
        if (!phxEvent) {
          if (dom_default.isUnloadableFormSubmit(e2)) {
            this.unload();
          }
          return;
        }
        e2.preventDefault();
        this.withinOwners(e2.target, (view) => {
          js_default.exec(e2, "submit", phxEvent, view, e2.target, [
            "push",
            { submitter: e2.submitter }
          ]);
        });
      });
      for (const type of ["change", "input"]) {
        this.on(type, (e2) => {
          if (!dom_default.isFormAssociated(e2.target)) {
            return;
          }
          if (e2 instanceof CustomEvent && e2.target.form === void 0) {
            if (e2.detail && e2.detail.dispatcher) {
              throw new Error(
                `dispatching a custom ${type} event is only supported on input elements inside a form`
              );
            }
            return;
          }
          const input = e2.target;
          const phxChange = this.binding("change");
          if (this.blockPhxChangeWhileComposing && e2 instanceof InputEvent && e2.isComposing) {
            const key = `composition-listener-${type}`;
            if (!dom_default.private(input, key)) {
              dom_default.putPrivate(input, key, true);
              input.addEventListener(
                "compositionend",
                () => {
                  input.dispatchEvent(new Event(type, { bubbles: true }));
                  dom_default.deletePrivate(input, key);
                },
                { once: true }
              );
            }
            return;
          }
          const inputEvent = input.getAttribute(phxChange);
          const formEvent = input.form && input.form.getAttribute(phxChange);
          const phxEvent = inputEvent || formEvent;
          if (!phxEvent) {
            return;
          }
          if (input.type === "number" && input.validity && input.validity.badInput) {
            return;
          }
          const dispatcher = inputEvent ? input : input.form;
          const currentIterations = iterations;
          iterations++;
          const { at: at2, type: lastType } = dom_default.private(input, "prev-iteration") || {};
          if (at2 === currentIterations - 1 && type === "change" && lastType === "input") {
            return;
          }
          dom_default.putPrivate(input, "prev-iteration", {
            at: currentIterations,
            type
          });
          this.debounce(input, e2, type, () => {
            this.withinOwners(dispatcher, (view) => {
              dom_default.putPrivate(input, PHX_HAS_FOCUSED, true);
              js_default.exec(e2, "change", phxEvent, view, input, [
                "push",
                { _target: input.name, dispatcher }
              ]);
            });
          });
        });
      }
      this.on("reset", (e2) => {
        const form = e2.target;
        dom_default.resetForm(form);
        const input = Array.from(form.elements).find(
          (el) => "type" in el && el.type === "reset"
        );
        if (input) {
          window.requestAnimationFrame(() => {
            input.dispatchEvent(
              new Event("input", { bubbles: true, cancelable: false })
            );
          });
        }
      });
    }
    /** @internal */
    debounce(el, event, eventType, callback) {
      if (eventType === "blur" || eventType === "focusout") {
        return callback();
      }
      const phxDebounce = this.binding(PHX_DEBOUNCE);
      const phxThrottle = this.binding(PHX_THROTTLE);
      const defaultDebounce = this.defaults.debounce.toString();
      const defaultThrottle = this.defaults.throttle.toString();
      this.withinOwners(el, (view) => {
        const asyncFilter = () => !view.isDestroyed() && document.body.contains(el);
        dom_default.debounce(
          el,
          event,
          phxDebounce,
          defaultDebounce,
          phxThrottle,
          defaultThrottle,
          asyncFilter,
          () => {
            callback();
          }
        );
      });
    }
    /** @internal */
    silenceEvents(callback) {
      this.silenced = true;
      callback();
      this.silenced = false;
    }
    /** @internal */
    on(event, callback) {
      this.boundEventNames.add(event);
      window.addEventListener(event, (e2) => {
        if (!this.silenced) {
          callback(e2);
        }
      });
    }
    /** @internal */
    jsQuerySelectorAll(sourceEl, query, defaultQuery) {
      const all = this.domCallbacks.jsQuerySelectorAll;
      return all ? all(sourceEl, query, defaultQuery) : defaultQuery();
    }
  };
  var TransitionSet = class {
    constructor() {
      this.transitions = /* @__PURE__ */ new Set();
      this.promises = /* @__PURE__ */ new Set();
      this.pendingOps = [];
    }
    reset() {
      this.transitions.forEach((timer) => {
        clearTimeout(timer);
        this.transitions.delete(timer);
      });
      this.promises.clear();
      this.flushPendingOps();
    }
    after(callback) {
      if (this.size() === 0) {
        callback();
      } else {
        this.pushPendingOp(callback);
      }
    }
    addTransition(time, onStart, onDone) {
      onStart();
      const timer = setTimeout(() => {
        this.transitions.delete(timer);
        onDone();
        this.flushPendingOps();
      }, time);
      this.transitions.add(timer);
    }
    addAsyncTransition(promise) {
      this.promises.add(promise);
      promise.then(() => {
        this.promises.delete(promise);
        this.flushPendingOps();
      });
    }
    pushPendingOp(op) {
      this.pendingOps.push(op);
    }
    size() {
      return this.transitions.size + this.promises.size;
    }
    flushPendingOps() {
      if (this.size() > 0) {
        return;
      }
      const op = this.pendingOps.shift();
      if (op) {
        op();
        this.flushPendingOps();
      }
    }
  };

  // node_modules/phoenix/priv/static/phoenix.mjs
  var closure2 = (value) => {
    if (typeof value === "function") {
      return value;
    } else {
      let closure22 = function() {
        return value;
      };
      return closure22;
    }
  };
  var globalSelf = typeof self !== "undefined" ? self : null;
  var phxWindow = typeof window !== "undefined" ? window : null;
  var global = globalSelf || phxWindow || globalThis;
  var DEFAULT_VSN = "2.0.0";
  var SOCKET_STATES = { connecting: 0, open: 1, closing: 2, closed: 3 };
  var MAX_LONGPOLL_BATCH_SIZE = 100;
  var DEFAULT_TIMEOUT = 1e4;
  var WS_CLOSE_NORMAL = 1e3;
  var CHANNEL_STATES = {
    closed: "closed",
    errored: "errored",
    joined: "joined",
    joining: "joining",
    leaving: "leaving"
  };
  var CHANNEL_EVENTS = {
    close: "phx_close",
    error: "phx_error",
    join: "phx_join",
    reply: "phx_reply",
    leave: "phx_leave"
  };
  var TRANSPORTS = {
    longpoll: "longpoll",
    websocket: "websocket"
  };
  var XHR_STATES = {
    complete: 4
  };
  var AUTH_TOKEN_PREFIX = "base64url.bearer.phx.";
  var Push = class {
    constructor(channel, event, payload, timeout) {
      this.channel = channel;
      this.event = event;
      this.payload = payload || function() {
        return {};
      };
      this.receivedResp = null;
      this.timeout = timeout;
      this.timeoutTimer = null;
      this.recHooks = [];
      this.sent = false;
    }
    /**
     *
     * @param {number} timeout
     */
    resend(timeout) {
      this.timeout = timeout;
      this.reset();
      this.send();
    }
    /**
     *
     */
    send() {
      if (this.hasReceived("timeout")) {
        return;
      }
      this.startTimeout();
      this.sent = true;
      this.channel.socket.push({
        topic: this.channel.topic,
        event: this.event,
        payload: this.payload(),
        ref: this.ref,
        join_ref: this.channel.joinRef()
      });
    }
    /**
     *
     * @param {*} status
     * @param {*} callback
     */
    receive(status, callback) {
      if (this.hasReceived(status)) {
        callback(this.receivedResp.response);
      }
      this.recHooks.push({ status, callback });
      return this;
    }
    /**
     * @private
     */
    reset() {
      this.cancelRefEvent();
      this.ref = null;
      this.refEvent = null;
      this.receivedResp = null;
      this.sent = false;
    }
    /**
     * @private
     */
    matchReceive({ status, response, _ref }) {
      this.recHooks.filter((h2) => h2.status === status).forEach((h2) => h2.callback(response));
    }
    /**
     * @private
     */
    cancelRefEvent() {
      if (!this.refEvent) {
        return;
      }
      this.channel.off(this.refEvent);
    }
    /**
     * @private
     */
    cancelTimeout() {
      clearTimeout(this.timeoutTimer);
      this.timeoutTimer = null;
    }
    /**
     * @private
     */
    startTimeout() {
      if (this.timeoutTimer) {
        this.cancelTimeout();
      }
      this.cancelRefEvent();
      this.ref = this.channel.socket.makeRef();
      this.refEvent = this.channel.replyEventName(this.ref);
      this.channel.on(this.refEvent, (payload) => {
        this.cancelRefEvent();
        this.cancelTimeout();
        this.receivedResp = payload;
        this.matchReceive(payload);
      });
      this.timeoutTimer = setTimeout(() => {
        this.trigger("timeout", {});
      }, this.timeout);
    }
    /**
     * @private
     */
    hasReceived(status) {
      return this.receivedResp && this.receivedResp.status === status;
    }
    /**
     * @private
     */
    trigger(status, response) {
      this.channel.trigger(this.refEvent, { status, response });
    }
  };
  var Timer = class {
    constructor(callback, timerCalc) {
      this.callback = callback;
      this.timerCalc = timerCalc;
      this.timer = null;
      this.tries = 0;
    }
    reset() {
      this.tries = 0;
      clearTimeout(this.timer);
    }
    /**
     * Cancels any previous scheduleTimeout and schedules callback
     */
    scheduleTimeout() {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        this.tries = this.tries + 1;
        this.callback();
      }, this.timerCalc(this.tries + 1));
    }
  };
  var Channel = class {
    constructor(topic, params, socket) {
      this.state = CHANNEL_STATES.closed;
      this.topic = topic;
      this.params = closure2(params || {});
      this.socket = socket;
      this.bindings = [];
      this.bindingRef = 0;
      this.timeout = this.socket.timeout;
      this.joinedOnce = false;
      this.joinPush = new Push(this, CHANNEL_EVENTS.join, this.params, this.timeout);
      this.pushBuffer = [];
      this.stateChangeRefs = [];
      this.rejoinTimer = new Timer(() => {
        if (this.socket.isConnected()) {
          this.rejoin();
        }
      }, this.socket.rejoinAfterMs);
      this.stateChangeRefs.push(this.socket.onError(() => this.rejoinTimer.reset()));
      this.stateChangeRefs.push(
        this.socket.onOpen(() => {
          this.rejoinTimer.reset();
          if (this.isErrored()) {
            this.rejoin();
          }
        })
      );
      this.joinPush.receive("ok", () => {
        this.state = CHANNEL_STATES.joined;
        this.rejoinTimer.reset();
        this.pushBuffer.forEach((pushEvent) => pushEvent.send());
        this.pushBuffer = [];
      });
      this.joinPush.receive("error", () => {
        this.state = CHANNEL_STATES.errored;
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.onClose(() => {
        this.rejoinTimer.reset();
        if (this.socket.hasLogger())
          this.socket.log("channel", `close ${this.topic} ${this.joinRef()}`);
        this.state = CHANNEL_STATES.closed;
        this.socket.remove(this);
      });
      this.onError((reason) => {
        if (this.socket.hasLogger())
          this.socket.log("channel", `error ${this.topic}`, reason);
        if (this.isJoining()) {
          this.joinPush.reset();
        }
        this.state = CHANNEL_STATES.errored;
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.joinPush.receive("timeout", () => {
        if (this.socket.hasLogger())
          this.socket.log("channel", `timeout ${this.topic} (${this.joinRef()})`, this.joinPush.timeout);
        let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure2({}), this.timeout);
        leavePush.send();
        this.state = CHANNEL_STATES.errored;
        this.joinPush.reset();
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.on(CHANNEL_EVENTS.reply, (payload, ref) => {
        this.trigger(this.replyEventName(ref), payload);
      });
    }
    /**
     * Join the channel
     * @param {integer} timeout
     * @returns {Push}
     */
    join(timeout = this.timeout) {
      if (this.joinedOnce) {
        throw new Error("tried to join multiple times. 'join' can only be called a single time per channel instance");
      } else {
        this.timeout = timeout;
        this.joinedOnce = true;
        this.rejoin();
        return this.joinPush;
      }
    }
    /**
     * Hook into channel close
     * @param {Function} callback
     */
    onClose(callback) {
      this.on(CHANNEL_EVENTS.close, callback);
    }
    /**
     * Hook into channel errors
     * @param {Function} callback
     */
    onError(callback) {
      return this.on(CHANNEL_EVENTS.error, (reason) => callback(reason));
    }
    /**
     * Subscribes on channel events
     *
     * Subscription returns a ref counter, which can be used later to
     * unsubscribe the exact event listener
     *
     * @example
     * const ref1 = channel.on("event", do_stuff)
     * const ref2 = channel.on("event", do_other_stuff)
     * channel.off("event", ref1)
     * // Since unsubscription, do_stuff won't fire,
     * // while do_other_stuff will keep firing on the "event"
     *
     * @param {string} event
     * @param {Function} callback
     * @returns {integer} ref
     */
    on(event, callback) {
      let ref = this.bindingRef++;
      this.bindings.push({ event, ref, callback });
      return ref;
    }
    /**
     * Unsubscribes off of channel events
     *
     * Use the ref returned from a channel.on() to unsubscribe one
     * handler, or pass nothing for the ref to unsubscribe all
     * handlers for the given event.
     *
     * @example
     * // Unsubscribe the do_stuff handler
     * const ref1 = channel.on("event", do_stuff)
     * channel.off("event", ref1)
     *
     * // Unsubscribe all handlers from event
     * channel.off("event")
     *
     * @param {string} event
     * @param {integer} ref
     */
    off(event, ref) {
      this.bindings = this.bindings.filter((bind) => {
        return !(bind.event === event && (typeof ref === "undefined" || ref === bind.ref));
      });
    }
    /**
     * @private
     */
    canPush() {
      return this.socket.isConnected() && this.isJoined();
    }
    /**
     * Sends a message `event` to phoenix with the payload `payload`.
     * Phoenix receives this in the `handle_in(event, payload, socket)`
     * function. if phoenix replies or it times out (default 10000ms),
     * then optionally the reply can be received.
     *
     * @example
     * channel.push("event")
     *   .receive("ok", payload => console.log("phoenix replied:", payload))
     *   .receive("error", err => console.log("phoenix errored", err))
     *   .receive("timeout", () => console.log("timed out pushing"))
     * @param {string} event
     * @param {Object} payload
     * @param {number} [timeout]
     * @returns {Push}
     */
    push(event, payload, timeout = this.timeout) {
      payload = payload || {};
      if (!this.joinedOnce) {
        throw new Error(`tried to push '${event}' to '${this.topic}' before joining. Use channel.join() before pushing events`);
      }
      let pushEvent = new Push(this, event, function() {
        return payload;
      }, timeout);
      if (this.canPush()) {
        pushEvent.send();
      } else {
        pushEvent.startTimeout();
        this.pushBuffer.push(pushEvent);
      }
      return pushEvent;
    }
    /** Leaves the channel
     *
     * Unsubscribes from server events, and
     * instructs channel to terminate on server
     *
     * Triggers onClose() hooks
     *
     * To receive leave acknowledgements, use the `receive`
     * hook to bind to the server ack, ie:
     *
     * @example
     * channel.leave().receive("ok", () => alert("left!") )
     *
     * @param {integer} timeout
     * @returns {Push}
     */
    leave(timeout = this.timeout) {
      this.rejoinTimer.reset();
      this.joinPush.cancelTimeout();
      this.state = CHANNEL_STATES.leaving;
      let onClose = () => {
        if (this.socket.hasLogger())
          this.socket.log("channel", `leave ${this.topic}`);
        this.trigger(CHANNEL_EVENTS.close, "leave");
      };
      let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure2({}), timeout);
      leavePush.receive("ok", () => onClose()).receive("timeout", () => onClose());
      leavePush.send();
      if (!this.canPush()) {
        leavePush.trigger("ok", {});
      }
      return leavePush;
    }
    /**
     * Overridable message hook
     *
     * Receives all events for specialized message handling
     * before dispatching to the channel callbacks.
     *
     * Must return the payload, modified or unmodified
     * @param {string} event
     * @param {Object} payload
     * @param {integer} ref
     * @returns {Object}
     */
    onMessage(_event, payload, _ref) {
      return payload;
    }
    /**
     * @private
     */
    isMember(topic, event, payload, joinRef) {
      if (this.topic !== topic) {
        return false;
      }
      if (joinRef && joinRef !== this.joinRef()) {
        if (this.socket.hasLogger())
          this.socket.log("channel", "dropping outdated message", { topic, event, payload, joinRef });
        return false;
      } else {
        return true;
      }
    }
    /**
     * @private
     */
    joinRef() {
      return this.joinPush.ref;
    }
    /**
     * @private
     */
    rejoin(timeout = this.timeout) {
      if (this.isLeaving()) {
        return;
      }
      this.socket.leaveOpenTopic(this.topic);
      this.state = CHANNEL_STATES.joining;
      this.joinPush.resend(timeout);
    }
    /**
     * @private
     */
    trigger(event, payload, ref, joinRef) {
      let handledPayload = this.onMessage(event, payload, ref, joinRef);
      if (payload && !handledPayload) {
        throw new Error("channel onMessage callbacks must return the payload, modified or unmodified");
      }
      let eventBindings = this.bindings.filter((bind) => bind.event === event);
      for (let i = 0; i < eventBindings.length; i++) {
        let bind = eventBindings[i];
        bind.callback(handledPayload, ref, joinRef || this.joinRef());
      }
    }
    /**
     * @private
     */
    replyEventName(ref) {
      return `chan_reply_${ref}`;
    }
    /**
     * @private
     */
    isClosed() {
      return this.state === CHANNEL_STATES.closed;
    }
    /**
     * @private
     */
    isErrored() {
      return this.state === CHANNEL_STATES.errored;
    }
    /**
     * @private
     */
    isJoined() {
      return this.state === CHANNEL_STATES.joined;
    }
    /**
     * @private
     */
    isJoining() {
      return this.state === CHANNEL_STATES.joining;
    }
    /**
     * @private
     */
    isLeaving() {
      return this.state === CHANNEL_STATES.leaving;
    }
  };
  var Ajax = class {
    static request(method, endPoint, headers, body, timeout, ontimeout, callback) {
      if (global.XDomainRequest) {
        let req = new global.XDomainRequest();
        return this.xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback);
      } else if (global.XMLHttpRequest) {
        let req = new global.XMLHttpRequest();
        return this.xhrRequest(req, method, endPoint, headers, body, timeout, ontimeout, callback);
      } else if (global.fetch && global.AbortController) {
        return this.fetchRequest(method, endPoint, headers, body, timeout, ontimeout, callback);
      } else {
        throw new Error("No suitable XMLHttpRequest implementation found");
      }
    }
    static fetchRequest(method, endPoint, headers, body, timeout, ontimeout, callback) {
      let options = {
        method,
        headers,
        body
      };
      let controller = null;
      let timeoutId = null;
      if (timeout) {
        controller = new AbortController();
        timeoutId = setTimeout(() => controller.abort(), timeout);
        options.signal = controller.signal;
      }
      global.fetch(endPoint, options).then((response) => response.text()).then((data) => this.parseJSON(data)).then((data) => {
        if (timeoutId) {
          clearTimeout(timeoutId);
        }
        callback && callback(data);
      }).catch((err) => {
        if (timeoutId) {
          clearTimeout(timeoutId);
        }
        if (err.name === "AbortError" && ontimeout) {
          ontimeout();
        } else {
          callback && callback(null);
        }
      });
      return controller;
    }
    static xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback) {
      req.timeout = timeout;
      req.open(method, endPoint);
      req.onload = () => {
        let response = this.parseJSON(req.responseText);
        callback && callback(response);
      };
      if (ontimeout) {
        req.ontimeout = ontimeout;
      }
      req.onprogress = () => {
      };
      req.send(body);
      return req;
    }
    static xhrRequest(req, method, endPoint, headers, body, timeout, ontimeout, callback) {
      req.open(method, endPoint, true);
      req.timeout = timeout;
      for (let [key, value] of Object.entries(headers)) {
        req.setRequestHeader(key, value);
      }
      req.onerror = () => callback && callback(null);
      req.onreadystatechange = () => {
        if (req.readyState === XHR_STATES.complete && callback) {
          let response = this.parseJSON(req.responseText);
          callback(response);
        }
      };
      if (ontimeout) {
        req.ontimeout = ontimeout;
      }
      req.send(body);
      return req;
    }
    static parseJSON(resp) {
      if (!resp || resp === "") {
        return null;
      }
      try {
        return JSON.parse(resp);
      } catch (e2) {
        console && console.log("failed to parse JSON response", resp);
        return null;
      }
    }
    static serialize(obj, parentKey) {
      let queryStr = [];
      for (var key in obj) {
        if (!Object.prototype.hasOwnProperty.call(obj, key)) {
          continue;
        }
        let paramKey = parentKey ? `${parentKey}[${key}]` : key;
        let paramVal = obj[key];
        if (typeof paramVal === "object") {
          queryStr.push(this.serialize(paramVal, paramKey));
        } else {
          queryStr.push(encodeURIComponent(paramKey) + "=" + encodeURIComponent(paramVal));
        }
      }
      return queryStr.join("&");
    }
    static appendParams(url, params) {
      if (Object.keys(params).length === 0) {
        return url;
      }
      let prefix = url.match(/\?/) ? "&" : "?";
      return `${url}${prefix}${this.serialize(params)}`;
    }
  };
  var arrayBufferToBase64 = (buffer) => {
    let binary = "";
    let bytes = new Uint8Array(buffer);
    let len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  };
  var LongPoll = class {
    constructor(endPoint, protocols) {
      if (protocols && protocols.length === 2 && protocols[1].startsWith(AUTH_TOKEN_PREFIX)) {
        this.authToken = atob(protocols[1].slice(AUTH_TOKEN_PREFIX.length));
      }
      this.endPoint = null;
      this.token = null;
      this.skipHeartbeat = true;
      this.reqs = /* @__PURE__ */ new Set();
      this.awaitingBatchAck = false;
      this.currentBatch = null;
      this.currentBatchTimer = null;
      this.batchBuffer = [];
      this.onopen = function() {
      };
      this.onerror = function() {
      };
      this.onmessage = function() {
      };
      this.onclose = function() {
      };
      this.pollEndpoint = this.normalizeEndpoint(endPoint);
      this.readyState = SOCKET_STATES.connecting;
      setTimeout(() => this.poll(), 0);
    }
    normalizeEndpoint(endPoint) {
      return endPoint.replace("ws://", "http://").replace("wss://", "https://").replace(new RegExp("(.*)/" + TRANSPORTS.websocket), "$1/" + TRANSPORTS.longpoll);
    }
    endpointURL() {
      return Ajax.appendParams(this.pollEndpoint, { token: this.token });
    }
    closeAndRetry(code, reason, wasClean) {
      this.close(code, reason, wasClean);
      this.readyState = SOCKET_STATES.connecting;
    }
    ontimeout() {
      this.onerror("timeout");
      this.closeAndRetry(1005, "timeout", false);
    }
    isActive() {
      return this.readyState === SOCKET_STATES.open || this.readyState === SOCKET_STATES.connecting;
    }
    poll() {
      const headers = { "Accept": "application/json" };
      if (this.authToken) {
        headers["X-Phoenix-AuthToken"] = this.authToken;
      }
      this.ajax("GET", headers, null, () => this.ontimeout(), (resp) => {
        if (resp) {
          var { status, token, messages } = resp;
          if (status === 410 && this.token !== null) {
            this.onerror(410);
            this.closeAndRetry(3410, "session_gone", false);
            return;
          }
          this.token = token;
        } else {
          status = 0;
        }
        switch (status) {
          case 200:
            messages.forEach((msg) => {
              setTimeout(() => this.onmessage({ data: msg }), 0);
            });
            this.poll();
            break;
          case 204:
            this.poll();
            break;
          case 410:
            this.readyState = SOCKET_STATES.open;
            this.onopen({});
            this.poll();
            break;
          case 403:
            this.onerror(403);
            this.close(1008, "forbidden", false);
            break;
          case 0:
          case 500:
            this.onerror(500);
            this.closeAndRetry(1011, "internal server error", 500);
            break;
          default:
            throw new Error(`unhandled poll status ${status}`);
        }
      });
    }
    // we collect all pushes within the current event loop by
    // setTimeout 0, which optimizes back-to-back procedural
    // pushes against an empty buffer
    send(body) {
      if (typeof body !== "string") {
        body = arrayBufferToBase64(body);
      }
      if (this.currentBatch) {
        this.currentBatch.push(body);
      } else if (this.awaitingBatchAck) {
        this.batchBuffer.push(body);
      } else {
        this.currentBatch = [body];
        this.currentBatchTimer = setTimeout(() => {
          this.batchSend(this.currentBatch);
          this.currentBatch = null;
        }, 0);
      }
    }
    batchSend(messages, offset = 0) {
      this.awaitingBatchAck = true;
      const next = offset + MAX_LONGPOLL_BATCH_SIZE;
      const batch = messages.slice(offset, next);
      this.ajax("POST", { "Content-Type": "application/x-ndjson" }, batch.join("\n"), () => this.ontimeout(), (resp) => {
        if (!resp || resp.status !== 200) {
          this.awaitingBatchAck = false;
          this.onerror(resp && resp.status);
          this.closeAndRetry(1011, "internal server error", false);
        } else if (next < messages.length) {
          this.batchSend(messages, next);
        } else if (this.batchBuffer.length > 0) {
          this.batchSend(this.batchBuffer);
          this.batchBuffer = [];
        } else {
          this.awaitingBatchAck = false;
        }
      });
    }
    close(code, reason, wasClean) {
      for (let req of this.reqs) {
        req.abort();
      }
      this.readyState = SOCKET_STATES.closed;
      let opts = Object.assign({ code: 1e3, reason: void 0, wasClean: true }, { code, reason, wasClean });
      this.batchBuffer = [];
      this.awaitingBatchAck = false;
      clearTimeout(this.currentBatchTimer);
      this.currentBatchTimer = null;
      if (typeof CloseEvent !== "undefined") {
        this.onclose(new CloseEvent("close", opts));
      } else {
        this.onclose(opts);
      }
    }
    ajax(method, headers, body, onCallerTimeout, callback) {
      let req;
      let ontimeout = () => {
        this.reqs.delete(req);
        onCallerTimeout();
      };
      req = Ajax.request(method, this.endpointURL(), headers, body, this.timeout, ontimeout, (resp) => {
        this.reqs.delete(req);
        if (this.isActive()) {
          callback(resp);
        }
      });
      this.reqs.add(req);
    }
  };
  var serializer_default = {
    HEADER_LENGTH: 1,
    META_LENGTH: 4,
    KINDS: { push: 0, reply: 1, broadcast: 2 },
    encode(msg, callback) {
      if (msg.payload.constructor === ArrayBuffer) {
        return callback(this.binaryEncode(msg));
      } else {
        let payload = [msg.join_ref, msg.ref, msg.topic, msg.event, msg.payload];
        return callback(JSON.stringify(payload));
      }
    },
    decode(rawPayload, callback) {
      if (rawPayload.constructor === ArrayBuffer) {
        return callback(this.binaryDecode(rawPayload));
      } else {
        let [join_ref, ref, topic, event, payload] = JSON.parse(rawPayload);
        return callback({ join_ref, ref, topic, event, payload });
      }
    },
    // private
    binaryEncode(message) {
      let { join_ref, ref, event, topic, payload } = message;
      let encoder = new TextEncoder();
      let joinRefBytes = encoder.encode(join_ref);
      let refBytes = encoder.encode(ref);
      let topicBytes = encoder.encode(topic);
      let eventBytes = encoder.encode(event);
      this.assertFieldSize(joinRefBytes.byteLength, "join_ref");
      this.assertFieldSize(refBytes.byteLength, "ref");
      this.assertFieldSize(topicBytes.byteLength, "topic");
      this.assertFieldSize(eventBytes.byteLength, "event");
      let metaLength = this.META_LENGTH + joinRefBytes.byteLength + refBytes.byteLength + topicBytes.byteLength + eventBytes.byteLength;
      let header = new ArrayBuffer(this.HEADER_LENGTH + metaLength);
      let headerBytes = new Uint8Array(header);
      let view = new DataView(header);
      let offset = 0;
      view.setUint8(offset++, this.KINDS.push);
      view.setUint8(offset++, joinRefBytes.byteLength);
      view.setUint8(offset++, refBytes.byteLength);
      view.setUint8(offset++, topicBytes.byteLength);
      view.setUint8(offset++, eventBytes.byteLength);
      headerBytes.set(joinRefBytes, offset);
      offset += joinRefBytes.byteLength;
      headerBytes.set(refBytes, offset);
      offset += refBytes.byteLength;
      headerBytes.set(topicBytes, offset);
      offset += topicBytes.byteLength;
      headerBytes.set(eventBytes, offset);
      offset += eventBytes.byteLength;
      var combined = new Uint8Array(header.byteLength + payload.byteLength);
      combined.set(headerBytes, 0);
      combined.set(new Uint8Array(payload), header.byteLength);
      return combined.buffer;
    },
    assertFieldSize(size2, name) {
      if (size2 > 255) {
        throw new Error(`unable to convert ${name} to binary: must be less than or equal to 255 bytes, but is ${size2} bytes`);
      }
    },
    binaryDecode(buffer) {
      let view = new DataView(buffer);
      let kind = view.getUint8(0);
      let decoder = new TextDecoder();
      switch (kind) {
        case this.KINDS.push:
          return this.decodePush(buffer, view, decoder);
        case this.KINDS.reply:
          return this.decodeReply(buffer, view, decoder);
        case this.KINDS.broadcast:
          return this.decodeBroadcast(buffer, view, decoder);
      }
    },
    decodePush(buffer, view, decoder) {
      let joinRefSize = view.getUint8(1);
      let topicSize = view.getUint8(2);
      let eventSize = view.getUint8(3);
      let offset = this.HEADER_LENGTH + this.META_LENGTH - 1;
      let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
      offset = offset + joinRefSize;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      return { join_ref: joinRef, ref: null, topic, event, payload: data };
    },
    decodeReply(buffer, view, decoder) {
      let joinRefSize = view.getUint8(1);
      let refSize = view.getUint8(2);
      let topicSize = view.getUint8(3);
      let eventSize = view.getUint8(4);
      let offset = this.HEADER_LENGTH + this.META_LENGTH;
      let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
      offset = offset + joinRefSize;
      let ref = decoder.decode(buffer.slice(offset, offset + refSize));
      offset = offset + refSize;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      let payload = { status: event, response: data };
      return { join_ref: joinRef, ref, topic, event: CHANNEL_EVENTS.reply, payload };
    },
    decodeBroadcast(buffer, view, decoder) {
      let topicSize = view.getUint8(1);
      let eventSize = view.getUint8(2);
      let offset = this.HEADER_LENGTH + 2;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      return { join_ref: null, ref: null, topic, event, payload: data };
    }
  };
  var Socket = class {
    constructor(endPoint, opts = {}) {
      this.stateChangeCallbacks = { open: [], close: [], error: [], message: [] };
      this.channels = [];
      this.sendBuffer = [];
      this.ref = 0;
      this.fallbackRef = null;
      this.timeout = opts.timeout || DEFAULT_TIMEOUT;
      this.transport = opts.transport || global.WebSocket || LongPoll;
      this.primaryPassedHealthCheck = false;
      this.longPollFallbackMs = opts.longPollFallbackMs;
      this.fallbackTimer = null;
      this.sessionStore = opts.sessionStorage || global && global.sessionStorage;
      this.establishedConnections = 0;
      this.defaultEncoder = serializer_default.encode.bind(serializer_default);
      this.defaultDecoder = serializer_default.decode.bind(serializer_default);
      this.closeWasClean = true;
      this.disconnecting = false;
      this.binaryType = opts.binaryType || "arraybuffer";
      this.connectClock = 1;
      if (this.transport !== LongPoll) {
        this.encode = opts.encode || this.defaultEncoder;
        this.decode = opts.decode || this.defaultDecoder;
      } else {
        this.encode = this.defaultEncoder;
        this.decode = this.defaultDecoder;
      }
      let awaitingConnectionOnPageShow = null;
      if (phxWindow && phxWindow.addEventListener) {
        phxWindow.addEventListener("pagehide", (_e2) => {
          if (this.conn) {
            this.disconnect();
            awaitingConnectionOnPageShow = this.connectClock;
          }
        });
        phxWindow.addEventListener("pageshow", (_e2) => {
          if (awaitingConnectionOnPageShow === this.connectClock) {
            awaitingConnectionOnPageShow = null;
            this.connect();
          }
        });
        phxWindow.addEventListener("visibilitychange", () => {
          this.handleVisibilityChange();
        });
        phxWindow.document && phxWindow.document.addEventListener("resume", () => {
          this.handleVisibilityChange();
        });
      }
      this.heartbeatIntervalMs = opts.heartbeatIntervalMs || 3e4;
      this.rejoinAfterMs = (tries) => {
        if (opts.rejoinAfterMs) {
          return opts.rejoinAfterMs(tries);
        } else {
          return [1e3, 2e3, 5e3][tries - 1] || 1e4;
        }
      };
      this.reconnectAfterMs = (tries) => {
        if (opts.reconnectAfterMs) {
          return opts.reconnectAfterMs(tries);
        } else {
          return [10, 50, 100, 150, 200, 250, 500, 1e3, 2e3][tries - 1] || 5e3;
        }
      };
      this.logger = opts.logger || null;
      if (!this.logger && opts.debug) {
        this.logger = (kind, msg, data) => {
          console.log(`${kind}: ${msg}`, data);
        };
      }
      this.longpollerTimeout = opts.longpollerTimeout || 2e4;
      this.params = closure2(opts.params || {});
      this.endPoint = `${endPoint}/${TRANSPORTS.websocket}`;
      this.vsn = opts.vsn || DEFAULT_VSN;
      this.heartbeatTimeoutTimer = null;
      this.heartbeatTimer = null;
      this.pendingHeartbeatRef = null;
      this.reconnectTimer = new Timer(() => {
        if (this.pageHidden) {
          this.log("Not reconnecting as page is hidden!");
          this.teardown();
          return;
        }
        this.teardown(() => this.connect());
      }, this.reconnectAfterMs);
      this.authToken = opts.authToken && closure2(opts.authToken);
    }
    /**
     * @internal
     */
    get pageHidden() {
      return phxWindow && phxWindow.document ? phxWindow.document.visibilityState === "hidden" : false;
    }
    /**
     * @internal
     */
    handleVisibilityChange() {
      if (!this.pageHidden) {
        if (!this.isConnected() && !this.closeWasClean) {
          this.teardown(() => this.connect());
        }
      }
    }
    /**
     * Returns the LongPoll transport reference
     */
    getLongPollTransport() {
      return LongPoll;
    }
    /**
     * Disconnects and replaces the active transport
     *
     * @param {Function} newTransport - The new transport class to instantiate
     *
     */
    replaceTransport(newTransport) {
      this.connectClock++;
      this.closeWasClean = true;
      clearTimeout(this.fallbackTimer);
      this.reconnectTimer.reset();
      if (this.conn) {
        this.conn.close();
        this.conn = null;
      }
      this.transport = newTransport;
    }
    /**
     * Returns the socket protocol
     *
     * @returns {string}
     */
    protocol() {
      return location.protocol.match(/^https/) ? "wss" : "ws";
    }
    /**
     * The fully qualified socket url
     *
     * @returns {string}
     */
    endPointURL() {
      let uri = Ajax.appendParams(
        Ajax.appendParams(this.endPoint, this.params()),
        { vsn: this.vsn }
      );
      if (uri.charAt(0) !== "/") {
        return uri;
      }
      if (uri.charAt(1) === "/") {
        return `${this.protocol()}:${uri}`;
      }
      return `${this.protocol()}://${location.host}${uri}`;
    }
    /**
     * Disconnects the socket
     *
     * See https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent#Status_codes for valid status codes.
     *
     * @param {Function} callback - Optional callback which is called after socket is disconnected.
     * @param {integer} code - A status code for disconnection (Optional).
     * @param {string} reason - A textual description of the reason to disconnect. (Optional)
     */
    disconnect(callback, code, reason) {
      this.connectClock++;
      this.disconnecting = true;
      this.closeWasClean = true;
      clearTimeout(this.fallbackTimer);
      this.reconnectTimer.reset();
      this.teardown(() => {
        this.disconnecting = false;
        callback && callback();
      }, code, reason);
    }
    /**
     *
     * @param {Object} params - The params to send when connecting, for example `{user_id: userToken}`
     *
     * Passing params to connect is deprecated; pass them in the Socket constructor instead:
     * `new Socket("/socket", {params: {user_id: userToken}})`.
     */
    connect(params) {
      if (params) {
        console && console.log("passing params to connect is deprecated. Instead pass :params to the Socket constructor");
        this.params = closure2(params);
      }
      if (this.conn && !this.disconnecting) {
        return;
      }
      if (this.longPollFallbackMs && this.transport !== LongPoll) {
        this.connectWithFallback(LongPoll, this.longPollFallbackMs);
      } else {
        this.transportConnect();
      }
    }
    /**
     * Logs the message. Override `this.logger` for specialized logging. noops by default
     * @param {string} kind
     * @param {string} msg
     * @param {Object} data
     */
    log(kind, msg, data) {
      this.logger && this.logger(kind, msg, data);
    }
    /**
     * Returns true if a logger has been set on this socket.
     */
    hasLogger() {
      return this.logger !== null;
    }
    /**
     * Registers callbacks for connection open events
     *
     * @example socket.onOpen(function(){ console.info("the socket was opened") })
     *
     * @param {Function} callback
     */
    onOpen(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.open.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection close events
     * @param {Function} callback
     */
    onClose(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.close.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection error events
     *
     * @example socket.onError(function(error){ alert("An error occurred") })
     *
     * @param {Function} callback
     */
    onError(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.error.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection message events
     * @param {Function} callback
     */
    onMessage(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.message.push([ref, callback]);
      return ref;
    }
    /**
     * Pings the server and invokes the callback with the RTT in milliseconds
     * @param {Function} callback
     *
     * Returns true if the ping was pushed or false if unable to be pushed.
     */
    ping(callback) {
      if (!this.isConnected()) {
        return false;
      }
      let ref = this.makeRef();
      let startTime = Date.now();
      this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref });
      let onMsgRef = this.onMessage((msg) => {
        if (msg.ref === ref) {
          this.off([onMsgRef]);
          callback(Date.now() - startTime);
        }
      });
      return true;
    }
    /**
     * @private
     *
     * @param {Function}
     */
    transportName(transport) {
      switch (transport) {
        case LongPoll:
          return "LongPoll";
        default:
          return transport.name;
      }
    }
    /**
     * @private
     */
    transportConnect() {
      this.connectClock++;
      this.closeWasClean = false;
      let protocols = void 0;
      if (this.authToken) {
        protocols = ["phoenix", `${AUTH_TOKEN_PREFIX}${btoa(this.authToken()).replace(/=/g, "")}`];
      }
      this.conn = new this.transport(this.endPointURL(), protocols);
      this.conn.binaryType = this.binaryType;
      this.conn.timeout = this.longpollerTimeout;
      this.conn.onopen = () => this.onConnOpen();
      this.conn.onerror = (error) => this.onConnError(error);
      this.conn.onmessage = (event) => this.onConnMessage(event);
      this.conn.onclose = (event) => this.onConnClose(event);
    }
    getSession(key) {
      return this.sessionStore && this.sessionStore.getItem(key);
    }
    storeSession(key, val) {
      this.sessionStore && this.sessionStore.setItem(key, val);
    }
    connectWithFallback(fallbackTransport, fallbackThreshold = 2500) {
      clearTimeout(this.fallbackTimer);
      let established = false;
      let primaryTransport = true;
      let openRef, errorRef;
      let fallbackTransportName = this.transportName(fallbackTransport);
      let fallback = (reason) => {
        this.log("transport", `falling back to ${fallbackTransportName}...`, reason);
        this.off([openRef, errorRef]);
        primaryTransport = false;
        this.replaceTransport(fallbackTransport);
        this.transportConnect();
      };
      if (this.getSession(`phx:fallback:${fallbackTransportName}`)) {
        return fallback("memorized");
      }
      this.fallbackTimer = setTimeout(fallback, fallbackThreshold);
      errorRef = this.onError((reason) => {
        this.log("transport", "error", reason);
        if (primaryTransport && !established) {
          clearTimeout(this.fallbackTimer);
          fallback(reason);
        }
      });
      if (this.fallbackRef) {
        this.off([this.fallbackRef]);
      }
      this.fallbackRef = this.onOpen(() => {
        established = true;
        if (!primaryTransport) {
          let fallbackTransportName2 = this.transportName(fallbackTransport);
          if (!this.primaryPassedHealthCheck) {
            this.storeSession(`phx:fallback:${fallbackTransportName2}`, "true");
          }
          return this.log("transport", `established ${fallbackTransportName2} fallback`);
        }
        clearTimeout(this.fallbackTimer);
        this.fallbackTimer = setTimeout(fallback, fallbackThreshold);
        this.ping((rtt) => {
          this.log("transport", "connected to primary after", rtt);
          this.primaryPassedHealthCheck = true;
          clearTimeout(this.fallbackTimer);
        });
      });
      this.transportConnect();
    }
    clearHeartbeats() {
      clearTimeout(this.heartbeatTimer);
      clearTimeout(this.heartbeatTimeoutTimer);
    }
    onConnOpen() {
      if (this.hasLogger())
        this.log("transport", `${this.transportName(this.transport)} connected to ${this.endPointURL()}`);
      this.closeWasClean = false;
      this.disconnecting = false;
      this.establishedConnections++;
      this.flushSendBuffer();
      this.reconnectTimer.reset();
      this.resetHeartbeat();
      this.stateChangeCallbacks.open.forEach(([, callback]) => callback());
    }
    /**
     * @private
     */
    heartbeatTimeout() {
      if (this.pendingHeartbeatRef) {
        this.pendingHeartbeatRef = null;
        if (this.hasLogger()) {
          this.log("transport", "heartbeat timeout. Attempting to re-establish connection");
        }
        this.triggerChanError("heartbeat_timeout");
        this.closeWasClean = false;
        this.teardown(() => this.reconnectTimer.scheduleTimeout(), WS_CLOSE_NORMAL, "heartbeat timeout");
      }
    }
    resetHeartbeat() {
      if (this.conn && this.conn.skipHeartbeat) {
        return;
      }
      this.pendingHeartbeatRef = null;
      this.clearHeartbeats();
      this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
    }
    teardown(callback, code, reason) {
      if (!this.conn) {
        return callback && callback();
      }
      const connToClose = this.conn;
      this.waitForBufferDone(connToClose, () => {
        if (code) {
          connToClose.close(code, reason || "");
        } else {
          connToClose.close();
        }
        this.waitForSocketClosed(connToClose, () => {
          if (this.conn === connToClose) {
            this.conn.onopen = function() {
            };
            this.conn.onerror = function() {
            };
            this.conn.onmessage = function() {
            };
            this.conn.onclose = function() {
            };
            this.conn = null;
          }
          callback && callback();
        });
      });
    }
    waitForBufferDone(conn, callback, tries = 1) {
      if (tries === 5 || !conn.bufferedAmount) {
        callback();
        return;
      }
      setTimeout(() => {
        this.waitForBufferDone(conn, callback, tries + 1);
      }, 150 * tries);
    }
    waitForSocketClosed(conn, callback, tries = 1) {
      if (tries === 5 || conn.readyState === SOCKET_STATES.closed) {
        callback();
        return;
      }
      setTimeout(() => {
        this.waitForSocketClosed(conn, callback, tries + 1);
      }, 150 * tries);
    }
    onConnClose(event) {
      if (this.conn)
        this.conn.onclose = () => {
        };
      let closeCode = event && event.code;
      if (this.hasLogger())
        this.log("transport", "close", event);
      this.triggerChanError("connection_closed");
      this.clearHeartbeats();
      if (!this.closeWasClean && closeCode !== 1e3) {
        this.reconnectTimer.scheduleTimeout();
      }
      this.stateChangeCallbacks.close.forEach(([, callback]) => callback(event));
    }
    /**
     * @private
     */
    onConnError(error) {
      if (this.hasLogger())
        this.log("transport", "error", error);
      let transportBefore = this.transport;
      let establishedBefore = this.establishedConnections;
      this.stateChangeCallbacks.error.forEach(([, callback]) => {
        callback(error, transportBefore, establishedBefore);
      });
      if (transportBefore === this.transport || establishedBefore > 0) {
        this.triggerChanError("connection_error");
      }
    }
    /**
     * @private
     */
    triggerChanError(reason) {
      this.channels.forEach((channel) => {
        if (!(channel.isErrored() || channel.isLeaving() || channel.isClosed())) {
          channel.trigger(CHANNEL_EVENTS.error, { source: "transport", reason });
        }
      });
    }
    /**
     * @returns {string}
     */
    connectionState() {
      switch (this.conn && this.conn.readyState) {
        case SOCKET_STATES.connecting:
          return "connecting";
        case SOCKET_STATES.open:
          return "open";
        case SOCKET_STATES.closing:
          return "closing";
        default:
          return "closed";
      }
    }
    /**
     * @returns {boolean}
     */
    isConnected() {
      return this.connectionState() === "open";
    }
    /**
     * @private
     *
     * @param {Channel}
     */
    remove(channel) {
      this.off(channel.stateChangeRefs);
      this.channels = this.channels.filter((c2) => c2 !== channel);
    }
    /**
     * Removes `onOpen`, `onClose`, `onError,` and `onMessage` registrations.
     *
     * @param {refs} - list of refs returned by calls to
     *                 `onOpen`, `onClose`, `onError,` and `onMessage`
     */
    off(refs) {
      for (let key in this.stateChangeCallbacks) {
        this.stateChangeCallbacks[key] = this.stateChangeCallbacks[key].filter(([ref]) => {
          return refs.indexOf(ref) === -1;
        });
      }
    }
    /**
     * Initiates a new channel for the given topic
     *
     * @param {string} topic
     * @param {Object} chanParams - Parameters for the channel
     * @returns {Channel}
     */
    channel(topic, chanParams = {}) {
      let chan = new Channel(topic, chanParams, this);
      this.channels.push(chan);
      return chan;
    }
    /**
     * @param {Object} data
     */
    push(data) {
      if (this.hasLogger()) {
        let { topic, event, payload, ref, join_ref } = data;
        this.log("push", `${topic} ${event} (${join_ref}, ${ref})`, payload);
      }
      if (this.isConnected()) {
        this.encode(data, (result) => this.conn.send(result));
      } else {
        this.sendBuffer.push(() => this.encode(data, (result) => this.conn.send(result)));
      }
    }
    /**
     * Return the next message ref, accounting for overflows
     * @returns {string}
     */
    makeRef() {
      let newRef = this.ref + 1;
      if (newRef === this.ref) {
        this.ref = 0;
      } else {
        this.ref = newRef;
      }
      return this.ref.toString();
    }
    sendHeartbeat() {
      if (this.pendingHeartbeatRef && !this.isConnected()) {
        return;
      }
      this.pendingHeartbeatRef = this.makeRef();
      this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref: this.pendingHeartbeatRef });
      this.heartbeatTimeoutTimer = setTimeout(() => this.heartbeatTimeout(), this.heartbeatIntervalMs);
    }
    flushSendBuffer() {
      if (this.isConnected() && this.sendBuffer.length > 0) {
        this.sendBuffer.forEach((callback) => callback());
        this.sendBuffer = [];
      }
    }
    onConnMessage(rawMessage) {
      this.decode(rawMessage.data, (msg) => {
        let { topic, event, payload, ref, join_ref } = msg;
        if (ref && ref === this.pendingHeartbeatRef) {
          this.clearHeartbeats();
          this.pendingHeartbeatRef = null;
          this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
        }
        if (this.hasLogger())
          this.log("receive", `${payload.status || ""} ${topic} ${event} ${ref && "(" + ref + ")" || ""}`, payload);
        for (let i = 0; i < this.channels.length; i++) {
          const channel = this.channels[i];
          if (!channel.isMember(topic, event, payload, join_ref)) {
            continue;
          }
          channel.trigger(event, payload, ref, join_ref);
        }
        for (let i = 0; i < this.stateChangeCallbacks.message.length; i++) {
          let [, callback] = this.stateChangeCallbacks.message[i];
          callback(msg);
        }
      });
    }
    leaveOpenTopic(topic) {
      let dupChannel = this.channels.find((c2) => c2.topic === topic && (c2.isJoined() || c2.isJoining()));
      if (dupChannel) {
        if (this.hasLogger())
          this.log("transport", `leaving duplicate topic "${topic}"`);
        dupChannel.leave();
      }
    }
  };

  // node_modules/fancy-canvas/size.mjs
  function size(_a) {
    var width = _a.width, height = _a.height;
    if (width < 0) {
      throw new Error("Negative width is not allowed for Size");
    }
    if (height < 0) {
      throw new Error("Negative height is not allowed for Size");
    }
    return {
      width,
      height
    };
  }
  function equalSizes(first, second) {
    return first.width === second.width && first.height === second.height;
  }

  // node_modules/fancy-canvas/device-pixel-ratio.mjs
  var Observable = (
    /** @class */
    function() {
      function Observable2(win) {
        var _this = this;
        this._resolutionListener = function() {
          return _this._onResolutionChanged();
        };
        this._resolutionMediaQueryList = null;
        this._observers = [];
        this._window = win;
        this._installResolutionListener();
      }
      Observable2.prototype.dispose = function() {
        this._uninstallResolutionListener();
        this._window = null;
      };
      Object.defineProperty(Observable2.prototype, "value", {
        get: function() {
          return this._window.devicePixelRatio;
        },
        enumerable: false,
        configurable: true
      });
      Observable2.prototype.subscribe = function(next) {
        var _this = this;
        var observer = { next };
        this._observers.push(observer);
        return {
          unsubscribe: function() {
            _this._observers = _this._observers.filter(function(o2) {
              return o2 !== observer;
            });
          }
        };
      };
      Observable2.prototype._installResolutionListener = function() {
        if (this._resolutionMediaQueryList !== null) {
          throw new Error("Resolution listener is already installed");
        }
        var dppx = this._window.devicePixelRatio;
        this._resolutionMediaQueryList = this._window.matchMedia("all and (resolution: ".concat(dppx, "dppx)"));
        this._resolutionMediaQueryList.addListener(this._resolutionListener);
      };
      Observable2.prototype._uninstallResolutionListener = function() {
        if (this._resolutionMediaQueryList !== null) {
          this._resolutionMediaQueryList.removeListener(this._resolutionListener);
          this._resolutionMediaQueryList = null;
        }
      };
      Observable2.prototype._reinstallResolutionListener = function() {
        this._uninstallResolutionListener();
        this._installResolutionListener();
      };
      Observable2.prototype._onResolutionChanged = function() {
        var _this = this;
        this._observers.forEach(function(observer) {
          return observer.next(_this._window.devicePixelRatio);
        });
        this._reinstallResolutionListener();
      };
      return Observable2;
    }()
  );
  function createObservable(win) {
    return new Observable(win);
  }

  // node_modules/fancy-canvas/canvas-element-bitmap-size.mjs
  var DevicePixelContentBoxBinding = (
    /** @class */
    function() {
      function DevicePixelContentBoxBinding2(canvasElement, transformBitmapSize, options) {
        var _a;
        this._canvasElement = null;
        this._bitmapSizeChangedListeners = [];
        this._suggestedBitmapSize = null;
        this._suggestedBitmapSizeChangedListeners = [];
        this._devicePixelRatioObservable = null;
        this._canvasElementResizeObserver = null;
        this._canvasElement = canvasElement;
        this._canvasElementClientSize = size({
          width: this._canvasElement.clientWidth,
          height: this._canvasElement.clientHeight
        });
        this._transformBitmapSize = transformBitmapSize !== null && transformBitmapSize !== void 0 ? transformBitmapSize : function(size2) {
          return size2;
        };
        this._allowResizeObserver = (_a = options === null || options === void 0 ? void 0 : options.allowResizeObserver) !== null && _a !== void 0 ? _a : true;
        this._chooseAndInitObserver();
      }
      DevicePixelContentBoxBinding2.prototype.dispose = function() {
        var _a, _b;
        if (this._canvasElement === null) {
          throw new Error("Object is disposed");
        }
        (_a = this._canvasElementResizeObserver) === null || _a === void 0 ? void 0 : _a.disconnect();
        this._canvasElementResizeObserver = null;
        (_b = this._devicePixelRatioObservable) === null || _b === void 0 ? void 0 : _b.dispose();
        this._devicePixelRatioObservable = null;
        this._suggestedBitmapSizeChangedListeners.length = 0;
        this._bitmapSizeChangedListeners.length = 0;
        this._canvasElement = null;
      };
      Object.defineProperty(DevicePixelContentBoxBinding2.prototype, "canvasElement", {
        get: function() {
          if (this._canvasElement === null) {
            throw new Error("Object is disposed");
          }
          return this._canvasElement;
        },
        enumerable: false,
        configurable: true
      });
      Object.defineProperty(DevicePixelContentBoxBinding2.prototype, "canvasElementClientSize", {
        get: function() {
          return this._canvasElementClientSize;
        },
        enumerable: false,
        configurable: true
      });
      Object.defineProperty(DevicePixelContentBoxBinding2.prototype, "bitmapSize", {
        get: function() {
          return size({
            width: this.canvasElement.width,
            height: this.canvasElement.height
          });
        },
        enumerable: false,
        configurable: true
      });
      DevicePixelContentBoxBinding2.prototype.resizeCanvasElement = function(clientSize) {
        this._canvasElementClientSize = size(clientSize);
        this.canvasElement.style.width = "".concat(this._canvasElementClientSize.width, "px");
        this.canvasElement.style.height = "".concat(this._canvasElementClientSize.height, "px");
        this._invalidateBitmapSize();
      };
      DevicePixelContentBoxBinding2.prototype.subscribeBitmapSizeChanged = function(listener) {
        this._bitmapSizeChangedListeners.push(listener);
      };
      DevicePixelContentBoxBinding2.prototype.unsubscribeBitmapSizeChanged = function(listener) {
        this._bitmapSizeChangedListeners = this._bitmapSizeChangedListeners.filter(function(l2) {
          return l2 !== listener;
        });
      };
      Object.defineProperty(DevicePixelContentBoxBinding2.prototype, "suggestedBitmapSize", {
        get: function() {
          return this._suggestedBitmapSize;
        },
        enumerable: false,
        configurable: true
      });
      DevicePixelContentBoxBinding2.prototype.subscribeSuggestedBitmapSizeChanged = function(listener) {
        this._suggestedBitmapSizeChangedListeners.push(listener);
      };
      DevicePixelContentBoxBinding2.prototype.unsubscribeSuggestedBitmapSizeChanged = function(listener) {
        this._suggestedBitmapSizeChangedListeners = this._suggestedBitmapSizeChangedListeners.filter(function(l2) {
          return l2 !== listener;
        });
      };
      DevicePixelContentBoxBinding2.prototype.applySuggestedBitmapSize = function() {
        if (this._suggestedBitmapSize === null) {
          return;
        }
        var oldSuggestedSize = this._suggestedBitmapSize;
        this._suggestedBitmapSize = null;
        this._resizeBitmap(oldSuggestedSize);
        this._emitSuggestedBitmapSizeChanged(oldSuggestedSize, this._suggestedBitmapSize);
      };
      DevicePixelContentBoxBinding2.prototype._resizeBitmap = function(newSize) {
        var oldSize = this.bitmapSize;
        if (equalSizes(oldSize, newSize)) {
          return;
        }
        this.canvasElement.width = newSize.width;
        this.canvasElement.height = newSize.height;
        this._emitBitmapSizeChanged(oldSize, newSize);
      };
      DevicePixelContentBoxBinding2.prototype._emitBitmapSizeChanged = function(oldSize, newSize) {
        var _this = this;
        this._bitmapSizeChangedListeners.forEach(function(listener) {
          return listener.call(_this, oldSize, newSize);
        });
      };
      DevicePixelContentBoxBinding2.prototype._suggestNewBitmapSize = function(newSize) {
        var oldSuggestedSize = this._suggestedBitmapSize;
        var finalNewSize = size(this._transformBitmapSize(newSize, this._canvasElementClientSize));
        var newSuggestedSize = equalSizes(this.bitmapSize, finalNewSize) ? null : finalNewSize;
        if (oldSuggestedSize === null && newSuggestedSize === null) {
          return;
        }
        if (oldSuggestedSize !== null && newSuggestedSize !== null && equalSizes(oldSuggestedSize, newSuggestedSize)) {
          return;
        }
        this._suggestedBitmapSize = newSuggestedSize;
        this._emitSuggestedBitmapSizeChanged(oldSuggestedSize, newSuggestedSize);
      };
      DevicePixelContentBoxBinding2.prototype._emitSuggestedBitmapSizeChanged = function(oldSize, newSize) {
        var _this = this;
        this._suggestedBitmapSizeChangedListeners.forEach(function(listener) {
          return listener.call(_this, oldSize, newSize);
        });
      };
      DevicePixelContentBoxBinding2.prototype._chooseAndInitObserver = function() {
        var _this = this;
        if (!this._allowResizeObserver) {
          this._initDevicePixelRatioObservable();
          return;
        }
        isDevicePixelContentBoxSupported().then(function(isSupported) {
          return isSupported ? _this._initResizeObserver() : _this._initDevicePixelRatioObservable();
        });
      };
      DevicePixelContentBoxBinding2.prototype._initDevicePixelRatioObservable = function() {
        var _this = this;
        if (this._canvasElement === null) {
          return;
        }
        var win = canvasElementWindow(this._canvasElement);
        if (win === null) {
          throw new Error("No window is associated with the canvas");
        }
        this._devicePixelRatioObservable = createObservable(win);
        this._devicePixelRatioObservable.subscribe(function() {
          return _this._invalidateBitmapSize();
        });
        this._invalidateBitmapSize();
      };
      DevicePixelContentBoxBinding2.prototype._invalidateBitmapSize = function() {
        var _a, _b;
        if (this._canvasElement === null) {
          return;
        }
        var win = canvasElementWindow(this._canvasElement);
        if (win === null) {
          return;
        }
        var ratio = (_b = (_a = this._devicePixelRatioObservable) === null || _a === void 0 ? void 0 : _a.value) !== null && _b !== void 0 ? _b : win.devicePixelRatio;
        var canvasRects = this._canvasElement.getClientRects();
        var newSize = (
          // eslint-disable-next-line no-negated-condition
          canvasRects[0] !== void 0 ? predictedBitmapSize(canvasRects[0], ratio) : size({
            width: this._canvasElementClientSize.width * ratio,
            height: this._canvasElementClientSize.height * ratio
          })
        );
        this._suggestNewBitmapSize(newSize);
      };
      DevicePixelContentBoxBinding2.prototype._initResizeObserver = function() {
        var _this = this;
        if (this._canvasElement === null) {
          return;
        }
        this._canvasElementResizeObserver = new ResizeObserver(function(entries) {
          var entry = entries.find(function(entry2) {
            return entry2.target === _this._canvasElement;
          });
          if (!entry || !entry.devicePixelContentBoxSize || !entry.devicePixelContentBoxSize[0]) {
            return;
          }
          var entrySize = entry.devicePixelContentBoxSize[0];
          var newSize = size({
            width: entrySize.inlineSize,
            height: entrySize.blockSize
          });
          _this._suggestNewBitmapSize(newSize);
        });
        this._canvasElementResizeObserver.observe(this._canvasElement, { box: "device-pixel-content-box" });
      };
      return DevicePixelContentBoxBinding2;
    }()
  );
  function bindTo(canvasElement, target) {
    if (target.type === "device-pixel-content-box") {
      return new DevicePixelContentBoxBinding(canvasElement, target.transform, target.options);
    }
    throw new Error("Unsupported binding target");
  }
  function canvasElementWindow(canvasElement) {
    return canvasElement.ownerDocument.defaultView;
  }
  function isDevicePixelContentBoxSupported() {
    return new Promise(function(resolve) {
      var ro = new ResizeObserver(function(entries) {
        resolve(entries.every(function(entry) {
          return "devicePixelContentBoxSize" in entry;
        }));
        ro.disconnect();
      });
      ro.observe(document.body, { box: "device-pixel-content-box" });
    }).catch(function() {
      return false;
    });
  }
  function predictedBitmapSize(canvasRect, ratio) {
    return size({
      width: Math.round(canvasRect.left * ratio + canvasRect.width * ratio) - Math.round(canvasRect.left * ratio),
      height: Math.round(canvasRect.top * ratio + canvasRect.height * ratio) - Math.round(canvasRect.top * ratio)
    });
  }

  // node_modules/fancy-canvas/canvas-rendering-target.mjs
  var CanvasRenderingTarget2D = (
    /** @class */
    function() {
      function CanvasRenderingTarget2D2(context, mediaSize, bitmapSize) {
        if (mediaSize.width === 0 || mediaSize.height === 0) {
          throw new TypeError("Rendering target could only be created on a media with positive width and height");
        }
        this._mediaSize = mediaSize;
        if (bitmapSize.width === 0 || bitmapSize.height === 0) {
          throw new TypeError("Rendering target could only be created using a bitmap with positive integer width and height");
        }
        this._bitmapSize = bitmapSize;
        this._context = context;
      }
      CanvasRenderingTarget2D2.prototype.useMediaCoordinateSpace = function(f2) {
        try {
          this._context.save();
          this._context.setTransform(1, 0, 0, 1, 0, 0);
          this._context.scale(this._horizontalPixelRatio, this._verticalPixelRatio);
          return f2({
            context: this._context,
            mediaSize: this._mediaSize
          });
        } finally {
          this._context.restore();
        }
      };
      CanvasRenderingTarget2D2.prototype.useBitmapCoordinateSpace = function(f2) {
        try {
          this._context.save();
          this._context.setTransform(1, 0, 0, 1, 0, 0);
          return f2({
            context: this._context,
            mediaSize: this._mediaSize,
            bitmapSize: this._bitmapSize,
            horizontalPixelRatio: this._horizontalPixelRatio,
            verticalPixelRatio: this._verticalPixelRatio
          });
        } finally {
          this._context.restore();
        }
      };
      Object.defineProperty(CanvasRenderingTarget2D2.prototype, "_horizontalPixelRatio", {
        get: function() {
          return this._bitmapSize.width / this._mediaSize.width;
        },
        enumerable: false,
        configurable: true
      });
      Object.defineProperty(CanvasRenderingTarget2D2.prototype, "_verticalPixelRatio", {
        get: function() {
          return this._bitmapSize.height / this._mediaSize.height;
        },
        enumerable: false,
        configurable: true
      });
      return CanvasRenderingTarget2D2;
    }()
  );
  function tryCreateCanvasRenderingTarget2D(binding, contextOptions) {
    var mediaSize = binding.canvasElementClientSize;
    if (mediaSize.width === 0 || mediaSize.height === 0) {
      return null;
    }
    var bitmapSize = binding.bitmapSize;
    if (bitmapSize.width === 0 || bitmapSize.height === 0) {
      return null;
    }
    var context = binding.canvasElement.getContext("2d", contextOptions);
    if (context === null) {
      return null;
    }
    return new CanvasRenderingTarget2D(context, mediaSize, bitmapSize);
  }

  // node_modules/lightweight-charts/dist/lightweight-charts.production.mjs
  var e = { upColor: "#26a69a", downColor: "#ef5350", wickVisible: true, borderVisible: true, borderColor: "#378658", borderUpColor: "#26a69a", borderDownColor: "#ef5350", wickColor: "#737375", wickUpColor: "#26a69a", wickDownColor: "#ef5350" };
  var r = { upColor: "#26a69a", downColor: "#ef5350", openVisible: true, thinBars: true };
  var h = { color: "#2196f3", lineStyle: 0, lineWidth: 3, lineType: 0, lineVisible: true, crosshairMarkerVisible: true, crosshairMarkerRadius: 4, crosshairMarkerBorderColor: "", crosshairMarkerBorderWidth: 2, crosshairMarkerBackgroundColor: "", lastPriceAnimation: 0, pointMarkersVisible: false };
  var l = { topColor: "rgba( 46, 220, 135, 0.4)", bottomColor: "rgba( 40, 221, 100, 0)", invertFilledArea: false, lineColor: "#33D778", lineStyle: 0, lineWidth: 3, lineType: 0, lineVisible: true, crosshairMarkerVisible: true, crosshairMarkerRadius: 4, crosshairMarkerBorderColor: "", crosshairMarkerBorderWidth: 2, crosshairMarkerBackgroundColor: "", lastPriceAnimation: 0, pointMarkersVisible: false };
  var a = { baseValue: { type: "price", price: 0 }, topFillColor1: "rgba(38, 166, 154, 0.28)", topFillColor2: "rgba(38, 166, 154, 0.05)", topLineColor: "rgba(38, 166, 154, 1)", bottomFillColor1: "rgba(239, 83, 80, 0.05)", bottomFillColor2: "rgba(239, 83, 80, 0.28)", bottomLineColor: "rgba(239, 83, 80, 1)", lineWidth: 3, lineStyle: 0, lineType: 0, lineVisible: true, crosshairMarkerVisible: true, crosshairMarkerRadius: 4, crosshairMarkerBorderColor: "", crosshairMarkerBorderWidth: 2, crosshairMarkerBackgroundColor: "", lastPriceAnimation: 0, pointMarkersVisible: false };
  var o = { color: "#26a69a", base: 0 };
  var _ = { color: "#2196f3" };
  var u = { title: "", visible: true, lastValueVisible: true, priceLineVisible: true, priceLineSource: 0, priceLineWidth: 1, priceLineColor: "", priceLineStyle: 2, baseLineVisible: true, baseLineWidth: 1, baseLineColor: "#B2B5BE", baseLineStyle: 0, priceFormat: { type: "price", precision: 2, minMove: 0.01 } };
  var c;
  var d;
  function f(t, i) {
    const n = { 0: [], 1: [t.lineWidth, t.lineWidth], 2: [2 * t.lineWidth, 2 * t.lineWidth], 3: [6 * t.lineWidth, 6 * t.lineWidth], 4: [t.lineWidth, 4 * t.lineWidth] }[i];
    t.setLineDash(n);
  }
  function v(t, i, n, s) {
    t.beginPath();
    const e2 = t.lineWidth % 2 ? 0.5 : 0;
    t.moveTo(n, i + e2), t.lineTo(s, i + e2), t.stroke();
  }
  function p(t, i) {
    if (!t)
      throw new Error("Assertion failed" + (i ? ": " + i : ""));
  }
  function m(t) {
    if (void 0 === t)
      throw new Error("Value is undefined");
    return t;
  }
  function b(t) {
    if (null === t)
      throw new Error("Value is null");
    return t;
  }
  function w(t) {
    return b(m(t));
  }
  !function(t) {
    t[t.Simple = 0] = "Simple", t[t.WithSteps = 1] = "WithSteps", t[t.Curved = 2] = "Curved";
  }(c || (c = {})), function(t) {
    t[t.Solid = 0] = "Solid", t[t.Dotted = 1] = "Dotted", t[t.Dashed = 2] = "Dashed", t[t.LargeDashed = 3] = "LargeDashed", t[t.SparseDotted = 4] = "SparseDotted";
  }(d || (d = {}));
  var g = { khaki: "#f0e68c", azure: "#f0ffff", aliceblue: "#f0f8ff", ghostwhite: "#f8f8ff", gold: "#ffd700", goldenrod: "#daa520", gainsboro: "#dcdcdc", gray: "#808080", green: "#008000", honeydew: "#f0fff0", floralwhite: "#fffaf0", lightblue: "#add8e6", lightcoral: "#f08080", lemonchiffon: "#fffacd", hotpink: "#ff69b4", lightyellow: "#ffffe0", greenyellow: "#adff2f", lightgoldenrodyellow: "#fafad2", limegreen: "#32cd32", linen: "#faf0e6", lightcyan: "#e0ffff", magenta: "#f0f", maroon: "#800000", olive: "#808000", orange: "#ffa500", oldlace: "#fdf5e6", mediumblue: "#0000cd", transparent: "#0000", lime: "#0f0", lightpink: "#ffb6c1", mistyrose: "#ffe4e1", moccasin: "#ffe4b5", midnightblue: "#191970", orchid: "#da70d6", mediumorchid: "#ba55d3", mediumturquoise: "#48d1cc", orangered: "#ff4500", royalblue: "#4169e1", powderblue: "#b0e0e6", red: "#f00", coral: "#ff7f50", turquoise: "#40e0d0", white: "#fff", whitesmoke: "#f5f5f5", wheat: "#f5deb3", teal: "#008080", steelblue: "#4682b4", bisque: "#ffe4c4", aquamarine: "#7fffd4", aqua: "#0ff", sienna: "#a0522d", silver: "#c0c0c0", springgreen: "#00ff7f", antiquewhite: "#faebd7", burlywood: "#deb887", brown: "#a52a2a", beige: "#f5f5dc", chocolate: "#d2691e", chartreuse: "#7fff00", cornflowerblue: "#6495ed", cornsilk: "#fff8dc", crimson: "#dc143c", cadetblue: "#5f9ea0", tomato: "#ff6347", fuchsia: "#f0f", blue: "#00f", salmon: "#fa8072", blanchedalmond: "#ffebcd", slateblue: "#6a5acd", slategray: "#708090", thistle: "#d8bfd8", tan: "#d2b48c", cyan: "#0ff", darkblue: "#00008b", darkcyan: "#008b8b", darkgoldenrod: "#b8860b", darkgray: "#a9a9a9", blueviolet: "#8a2be2", black: "#000", darkmagenta: "#8b008b", darkslateblue: "#483d8b", darkkhaki: "#bdb76b", darkorchid: "#9932cc", darkorange: "#ff8c00", darkgreen: "#006400", darkred: "#8b0000", dodgerblue: "#1e90ff", darkslategray: "#2f4f4f", dimgray: "#696969", deepskyblue: "#00bfff", firebrick: "#b22222", forestgreen: "#228b22", indigo: "#4b0082", ivory: "#fffff0", lavenderblush: "#fff0f5", feldspar: "#d19275", indianred: "#cd5c5c", lightgreen: "#90ee90", lightgrey: "#d3d3d3", lightskyblue: "#87cefa", lightslategray: "#789", lightslateblue: "#8470ff", snow: "#fffafa", lightseagreen: "#20b2aa", lightsalmon: "#ffa07a", darksalmon: "#e9967a", darkviolet: "#9400d3", mediumpurple: "#9370d8", mediumaquamarine: "#66cdaa", skyblue: "#87ceeb", lavender: "#e6e6fa", lightsteelblue: "#b0c4de", mediumvioletred: "#c71585", mintcream: "#f5fffa", navajowhite: "#ffdead", navy: "#000080", olivedrab: "#6b8e23", palevioletred: "#d87093", violetred: "#d02090", yellow: "#ff0", yellowgreen: "#9acd32", lawngreen: "#7cfc00", pink: "#ffc0cb", paleturquoise: "#afeeee", palegoldenrod: "#eee8aa", darkolivegreen: "#556b2f", darkseagreen: "#8fbc8f", darkturquoise: "#00ced1", peachpuff: "#ffdab9", deeppink: "#ff1493", violet: "#ee82ee", palegreen: "#98fb98", mediumseagreen: "#3cb371", peru: "#cd853f", saddlebrown: "#8b4513", sandybrown: "#f4a460", rosybrown: "#bc8f8f", purple: "#800080", seagreen: "#2e8b57", seashell: "#fff5ee", papayawhip: "#ffefd5", mediumslateblue: "#7b68ee", plum: "#dda0dd", mediumspringgreen: "#00fa9a" };
  function M(t) {
    return t < 0 ? 0 : t > 255 ? 255 : Math.round(t) || 0;
  }
  function x(t) {
    return t <= 0 || t > 1 ? Math.min(Math.max(t, 0), 1) : Math.round(1e4 * t) / 1e4;
  }
  var S = /^#([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])?$/i;
  var k = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})?$/i;
  var y = /^rgb\(\s*(-?\d{1,10})\s*,\s*(-?\d{1,10})\s*,\s*(-?\d{1,10})\s*\)$/;
  var C = /^rgba\(\s*(-?\d{1,10})\s*,\s*(-?\d{1,10})\s*,\s*(-?\d{1,10})\s*,\s*(-?\d*\.?\d+)\s*\)$/;
  function T(t) {
    (t = t.toLowerCase()) in g && (t = g[t]);
    {
      const i = C.exec(t) || y.exec(t);
      if (i)
        return [M(parseInt(i[1], 10)), M(parseInt(i[2], 10)), M(parseInt(i[3], 10)), x(i.length < 5 ? 1 : parseFloat(i[4]))];
    }
    {
      const i = k.exec(t);
      if (i)
        return [M(parseInt(i[1], 16)), M(parseInt(i[2], 16)), M(parseInt(i[3], 16)), 1];
    }
    {
      const i = S.exec(t);
      if (i)
        return [M(17 * parseInt(i[1], 16)), M(17 * parseInt(i[2], 16)), M(17 * parseInt(i[3], 16)), 1];
    }
    throw new Error(`Cannot parse color: ${t}`);
  }
  function P(t) {
    return 0.199 * t[0] + 0.687 * t[1] + 0.114 * t[2];
  }
  function R(t) {
    const i = T(t);
    return { t: `rgb(${i[0]}, ${i[1]}, ${i[2]})`, i: P(i) > 160 ? "black" : "white" };
  }
  var D = class {
    constructor() {
      this.h = [];
    }
    l(t, i, n) {
      const s = { o: t, _: i, u: true === n };
      this.h.push(s);
    }
    v(t) {
      const i = this.h.findIndex((i2) => t === i2.o);
      i > -1 && this.h.splice(i, 1);
    }
    p(t) {
      this.h = this.h.filter((i) => i._ !== t);
    }
    m(t, i, n) {
      const s = [...this.h];
      this.h = this.h.filter((t2) => !t2.u), s.forEach((s2) => s2.o(t, i, n));
    }
    M() {
      return this.h.length > 0;
    }
    S() {
      this.h = [];
    }
  };
  function V(t, ...i) {
    for (const n of i)
      for (const i2 in n)
        void 0 !== n[i2] && Object.prototype.hasOwnProperty.call(n, i2) && !["__proto__", "constructor", "prototype"].includes(i2) && ("object" != typeof n[i2] || void 0 === t[i2] || Array.isArray(n[i2]) ? t[i2] = n[i2] : V(t[i2], n[i2]));
    return t;
  }
  function O(t) {
    return "number" == typeof t && isFinite(t);
  }
  function B(t) {
    return "number" == typeof t && t % 1 == 0;
  }
  function A(t) {
    return "string" == typeof t;
  }
  function I(t) {
    return "boolean" == typeof t;
  }
  function z(t) {
    const i = t;
    if (!i || "object" != typeof i)
      return i;
    let n, s, e2;
    for (s in n = Array.isArray(i) ? [] : {}, i)
      i.hasOwnProperty(s) && (e2 = i[s], n[s] = e2 && "object" == typeof e2 ? z(e2) : e2);
    return n;
  }
  function L(t) {
    return null !== t;
  }
  function E(t) {
    return null === t ? void 0 : t;
  }
  var N = "-apple-system, BlinkMacSystemFont, 'Trebuchet MS', Roboto, Ubuntu, sans-serif";
  function F(t, i, n) {
    return void 0 === i && (i = N), `${n = void 0 !== n ? `${n} ` : ""}${t}px ${i}`;
  }
  var W = class {
    constructor(t) {
      this.k = { C: 1, T: 5, P: NaN, R: "", D: "", V: "", O: "", B: 0, A: 0, I: 0, L: 0, N: 0 }, this.F = t;
    }
    W() {
      const t = this.k, i = this.j(), n = this.H();
      return t.P === i && t.D === n || (t.P = i, t.D = n, t.R = F(i, n), t.L = 2.5 / 12 * i, t.B = t.L, t.A = i / 12 * t.T, t.I = i / 12 * t.T, t.N = 0), t.V = this.$(), t.O = this.U(), this.k;
    }
    $() {
      return this.F.W().layout.textColor;
    }
    U() {
      return this.F.q();
    }
    j() {
      return this.F.W().layout.fontSize;
    }
    H() {
      return this.F.W().layout.fontFamily;
    }
  };
  var j = class {
    constructor() {
      this.Y = [];
    }
    Z(t) {
      this.Y = t;
    }
    X(t, i, n) {
      this.Y.forEach((s) => {
        s.X(t, i, n);
      });
    }
  };
  var H = class {
    X(t, i, n) {
      t.useBitmapCoordinateSpace((t2) => this.K(t2, i, n));
    }
  };
  var $ = class extends H {
    constructor() {
      super(...arguments), this.G = null;
    }
    J(t) {
      this.G = t;
    }
    K({ context: t, horizontalPixelRatio: i, verticalPixelRatio: n }) {
      if (null === this.G || null === this.G.tt)
        return;
      const s = this.G.tt, e2 = this.G, r2 = Math.max(1, Math.floor(i)) % 2 / 2, h2 = (h3) => {
        t.beginPath();
        for (let l2 = s.to - 1; l2 >= s.from; --l2) {
          const s2 = e2.it[l2], a2 = Math.round(s2.nt * i) + r2, o2 = s2.st * n, _2 = h3 * n + r2;
          t.moveTo(a2, o2), t.arc(a2, o2, _2, 0, 2 * Math.PI);
        }
        t.fill();
      };
      e2.et > 0 && (t.fillStyle = e2.rt, h2(e2.ht + e2.et)), t.fillStyle = e2.lt, h2(e2.ht);
    }
  };
  function U() {
    return { it: [{ nt: 0, st: 0, ot: 0, _t: 0 }], lt: "", rt: "", ht: 0, et: 0, tt: null };
  }
  var q = { from: 0, to: 1 };
  var Y = class {
    constructor(t, i) {
      this.ut = new j(), this.ct = [], this.dt = [], this.ft = true, this.F = t, this.vt = i, this.ut.Z(this.ct);
    }
    bt(t) {
      const i = this.F.wt();
      i.length !== this.ct.length && (this.dt = i.map(U), this.ct = this.dt.map((t2) => {
        const i2 = new $();
        return i2.J(t2), i2;
      }), this.ut.Z(this.ct)), this.ft = true;
    }
    gt() {
      return this.ft && (this.Mt(), this.ft = false), this.ut;
    }
    Mt() {
      const t = 2 === this.vt.W().mode, i = this.F.wt(), n = this.vt.xt(), s = this.F.St();
      i.forEach((i2, e2) => {
        var r2;
        const h2 = this.dt[e2], l2 = i2.kt(n);
        if (t || null === l2 || !i2.yt())
          return void (h2.tt = null);
        const a2 = b(i2.Ct());
        h2.lt = l2.Tt, h2.ht = l2.ht, h2.et = l2.Pt, h2.it[0]._t = l2._t, h2.it[0].st = i2.Dt().Rt(l2._t, a2.Vt), h2.rt = null !== (r2 = l2.Ot) && void 0 !== r2 ? r2 : this.F.Bt(h2.it[0].st / i2.Dt().At()), h2.it[0].ot = n, h2.it[0].nt = s.It(n), h2.tt = q;
      });
    }
  };
  var Z = class extends H {
    constructor(t) {
      super(), this.zt = t;
    }
    K({ context: t, bitmapSize: i, horizontalPixelRatio: n, verticalPixelRatio: s }) {
      if (null === this.zt)
        return;
      const e2 = this.zt.Lt.yt, r2 = this.zt.Et.yt;
      if (!e2 && !r2)
        return;
      const h2 = Math.round(this.zt.nt * n), l2 = Math.round(this.zt.st * s);
      t.lineCap = "butt", e2 && h2 >= 0 && (t.lineWidth = Math.floor(this.zt.Lt.et * n), t.strokeStyle = this.zt.Lt.V, t.fillStyle = this.zt.Lt.V, f(t, this.zt.Lt.Nt), function(t2, i2, n2, s2) {
        t2.beginPath();
        const e3 = t2.lineWidth % 2 ? 0.5 : 0;
        t2.moveTo(i2 + e3, n2), t2.lineTo(i2 + e3, s2), t2.stroke();
      }(t, h2, 0, i.height)), r2 && l2 >= 0 && (t.lineWidth = Math.floor(this.zt.Et.et * s), t.strokeStyle = this.zt.Et.V, t.fillStyle = this.zt.Et.V, f(t, this.zt.Et.Nt), v(t, l2, 0, i.width));
    }
  };
  var X = class {
    constructor(t) {
      this.ft = true, this.Ft = { Lt: { et: 1, Nt: 0, V: "", yt: false }, Et: { et: 1, Nt: 0, V: "", yt: false }, nt: 0, st: 0 }, this.Wt = new Z(this.Ft), this.jt = t;
    }
    bt() {
      this.ft = true;
    }
    gt() {
      return this.ft && (this.Mt(), this.ft = false), this.Wt;
    }
    Mt() {
      const t = this.jt.yt(), i = b(this.jt.Ht()), n = i.$t().W().crosshair, s = this.Ft;
      if (2 === n.mode)
        return s.Et.yt = false, void (s.Lt.yt = false);
      s.Et.yt = t && this.jt.Ut(i), s.Lt.yt = t && this.jt.qt(), s.Et.et = n.horzLine.width, s.Et.Nt = n.horzLine.style, s.Et.V = n.horzLine.color, s.Lt.et = n.vertLine.width, s.Lt.Nt = n.vertLine.style, s.Lt.V = n.vertLine.color, s.nt = this.jt.Yt(), s.st = this.jt.Zt();
    }
  };
  function K(t, i, n, s, e2, r2) {
    t.fillRect(i + r2, n, s - 2 * r2, r2), t.fillRect(i + r2, n + e2 - r2, s - 2 * r2, r2), t.fillRect(i, n, r2, e2), t.fillRect(i + s - r2, n, r2, e2);
  }
  function G(t, i, n, s, e2, r2) {
    t.save(), t.globalCompositeOperation = "copy", t.fillStyle = r2, t.fillRect(i, n, s, e2), t.restore();
  }
  function J(t, i, n, s, e2, r2) {
    t.beginPath(), t.roundRect ? t.roundRect(i, n, s, e2, r2) : (t.lineTo(i + s - r2[1], n), 0 !== r2[1] && t.arcTo(i + s, n, i + s, n + r2[1], r2[1]), t.lineTo(i + s, n + e2 - r2[2]), 0 !== r2[2] && t.arcTo(i + s, n + e2, i + s - r2[2], n + e2, r2[2]), t.lineTo(i + r2[3], n + e2), 0 !== r2[3] && t.arcTo(i, n + e2, i, n + e2 - r2[3], r2[3]), t.lineTo(i, n + r2[0]), 0 !== r2[0] && t.arcTo(i, n, i + r2[0], n, r2[0]));
  }
  function Q(t, i, n, s, e2, r2, h2 = 0, l2 = [0, 0, 0, 0], a2 = "") {
    if (t.save(), !h2 || !a2 || a2 === r2)
      return J(t, i, n, s, e2, l2), t.fillStyle = r2, t.fill(), void t.restore();
    const o2 = h2 / 2;
    var _2;
    J(t, i + o2, n + o2, s - h2, e2 - h2, (_2 = -o2, l2.map((t2) => 0 === t2 ? t2 : t2 + _2))), "transparent" !== r2 && (t.fillStyle = r2, t.fill()), "transparent" !== a2 && (t.lineWidth = h2, t.strokeStyle = a2, t.closePath(), t.stroke()), t.restore();
  }
  function tt(t, i, n, s, e2, r2, h2) {
    t.save(), t.globalCompositeOperation = "copy";
    const l2 = t.createLinearGradient(0, 0, 0, e2);
    l2.addColorStop(0, r2), l2.addColorStop(1, h2), t.fillStyle = l2, t.fillRect(i, n, s, e2), t.restore();
  }
  var it = class {
    constructor(t, i) {
      this.J(t, i);
    }
    J(t, i) {
      this.zt = t, this.Xt = i;
    }
    At(t, i) {
      return this.zt.yt ? t.P + t.L + t.B : 0;
    }
    X(t, i, n, s) {
      if (!this.zt.yt || 0 === this.zt.Kt.length)
        return;
      const e2 = this.zt.V, r2 = this.Xt.t, h2 = t.useBitmapCoordinateSpace((t2) => {
        const h3 = t2.context;
        h3.font = i.R;
        const l2 = this.Gt(t2, i, n, s), a2 = l2.Jt;
        return l2.Qt ? Q(h3, a2.ti, a2.ii, a2.ni, a2.si, r2, a2.ei, [a2.ht, 0, 0, a2.ht], r2) : Q(h3, a2.ri, a2.ii, a2.ni, a2.si, r2, a2.ei, [0, a2.ht, a2.ht, 0], r2), this.zt.hi && (h3.fillStyle = e2, h3.fillRect(a2.ri, a2.li, a2.ai - a2.ri, a2.oi)), this.zt._i && (h3.fillStyle = i.O, h3.fillRect(l2.Qt ? a2.ui - a2.ei : 0, a2.ii, a2.ei, a2.ci - a2.ii)), l2;
      });
      t.useMediaCoordinateSpace(({ context: t2 }) => {
        const n2 = h2.di;
        t2.font = i.R, t2.textAlign = h2.Qt ? "right" : "left", t2.textBaseline = "middle", t2.fillStyle = e2, t2.fillText(this.zt.Kt, n2.fi, (n2.ii + n2.ci) / 2 + n2.pi);
      });
    }
    Gt(t, i, n, s) {
      var e2;
      const { context: r2, bitmapSize: h2, mediaSize: l2, horizontalPixelRatio: a2, verticalPixelRatio: o2 } = t, _2 = this.zt.hi || !this.zt.mi ? i.T : 0, u2 = this.zt.bi ? i.C : 0, c2 = i.L + this.Xt.wi, d2 = i.B + this.Xt.gi, f2 = i.A, v2 = i.I, p2 = this.zt.Kt, m2 = i.P, b2 = n.Mi(r2, p2), w2 = Math.ceil(n.xi(r2, p2)), g2 = m2 + c2 + d2, M2 = i.C + f2 + v2 + w2 + _2, x2 = Math.max(1, Math.floor(o2));
      let S2 = Math.round(g2 * o2);
      S2 % 2 != x2 % 2 && (S2 += 1);
      const k2 = u2 > 0 ? Math.max(1, Math.floor(u2 * a2)) : 0, y2 = Math.round(M2 * a2), C2 = Math.round(_2 * a2), T2 = null !== (e2 = this.Xt.Si) && void 0 !== e2 ? e2 : this.Xt.ki, P2 = Math.round(T2 * o2) - Math.floor(0.5 * o2), R2 = Math.floor(P2 + x2 / 2 - S2 / 2), D2 = R2 + S2, V2 = "right" === s, O2 = V2 ? l2.width - u2 : u2, B2 = V2 ? h2.width - k2 : k2;
      let A2, I2, z2;
      return V2 ? (A2 = B2 - y2, I2 = B2 - C2, z2 = O2 - _2 - f2 - u2) : (A2 = B2 + y2, I2 = B2 + C2, z2 = O2 + _2 + f2), { Qt: V2, Jt: { ii: R2, li: P2, ci: D2, ni: y2, si: S2, ht: 2 * a2, ei: k2, ti: A2, ri: B2, ai: I2, oi: x2, ui: h2.width }, di: { ii: R2 / o2, ci: D2 / o2, fi: z2, pi: b2 } };
    }
  };
  var nt = class {
    constructor(t) {
      this.yi = { ki: 0, t: "#000", gi: 0, wi: 0 }, this.Ci = { Kt: "", yt: false, hi: true, mi: false, Ot: "", V: "#FFF", _i: false, bi: false }, this.Ti = { Kt: "", yt: false, hi: false, mi: true, Ot: "", V: "#FFF", _i: true, bi: true }, this.ft = true, this.Pi = new (t || it)(this.Ci, this.yi), this.Ri = new (t || it)(this.Ti, this.yi);
    }
    Kt() {
      return this.Di(), this.Ci.Kt;
    }
    ki() {
      return this.Di(), this.yi.ki;
    }
    bt() {
      this.ft = true;
    }
    At(t, i = false) {
      return Math.max(this.Pi.At(t, i), this.Ri.At(t, i));
    }
    Vi() {
      return this.yi.Si || 0;
    }
    Oi(t) {
      this.yi.Si = t;
    }
    Bi() {
      return this.Di(), this.Ci.yt || this.Ti.yt;
    }
    Ai() {
      return this.Di(), this.Ci.yt;
    }
    gt(t) {
      return this.Di(), this.Ci.hi = this.Ci.hi && t.W().ticksVisible, this.Ti.hi = this.Ti.hi && t.W().ticksVisible, this.Pi.J(this.Ci, this.yi), this.Ri.J(this.Ti, this.yi), this.Pi;
    }
    Ii() {
      return this.Di(), this.Pi.J(this.Ci, this.yi), this.Ri.J(this.Ti, this.yi), this.Ri;
    }
    Di() {
      this.ft && (this.Ci.hi = true, this.Ti.hi = false, this.zi(this.Ci, this.Ti, this.yi));
    }
  };
  var st = class extends nt {
    constructor(t, i, n) {
      super(), this.jt = t, this.Li = i, this.Ei = n;
    }
    zi(t, i, n) {
      if (t.yt = false, 2 === this.jt.W().mode)
        return;
      const s = this.jt.W().horzLine;
      if (!s.labelVisible)
        return;
      const e2 = this.Li.Ct();
      if (!this.jt.yt() || this.Li.Ni() || null === e2)
        return;
      const r2 = R(s.labelBackgroundColor);
      n.t = r2.t, t.V = r2.i;
      const h2 = 2 / 12 * this.Li.P();
      n.wi = h2, n.gi = h2;
      const l2 = this.Ei(this.Li);
      n.ki = l2.ki, t.Kt = this.Li.Fi(l2._t, e2), t.yt = true;
    }
  };
  var et = /[1-9]/g;
  var rt = class {
    constructor() {
      this.zt = null;
    }
    J(t) {
      this.zt = t;
    }
    X(t, i) {
      if (null === this.zt || false === this.zt.yt || 0 === this.zt.Kt.length)
        return;
      const n = t.useMediaCoordinateSpace(({ context: t2 }) => (t2.font = i.R, Math.round(i.Wi.xi(t2, b(this.zt).Kt, et))));
      if (n <= 0)
        return;
      const s = i.ji, e2 = n + 2 * s, r2 = e2 / 2, h2 = this.zt.Hi;
      let l2 = this.zt.ki, a2 = Math.floor(l2 - r2) + 0.5;
      a2 < 0 ? (l2 += Math.abs(0 - a2), a2 = Math.floor(l2 - r2) + 0.5) : a2 + e2 > h2 && (l2 -= Math.abs(h2 - (a2 + e2)), a2 = Math.floor(l2 - r2) + 0.5);
      const o2 = a2 + e2, _2 = Math.ceil(0 + i.C + i.T + i.L + i.P + i.B);
      t.useBitmapCoordinateSpace(({ context: t2, horizontalPixelRatio: n2, verticalPixelRatio: s2 }) => {
        const e3 = b(this.zt);
        t2.fillStyle = e3.t;
        const r3 = Math.round(a2 * n2), h3 = Math.round(0 * s2), l3 = Math.round(o2 * n2), u2 = Math.round(_2 * s2), c2 = Math.round(2 * n2);
        if (t2.beginPath(), t2.moveTo(r3, h3), t2.lineTo(r3, u2 - c2), t2.arcTo(r3, u2, r3 + c2, u2, c2), t2.lineTo(l3 - c2, u2), t2.arcTo(l3, u2, l3, u2 - c2, c2), t2.lineTo(l3, h3), t2.fill(), e3.hi) {
          const r4 = Math.round(e3.ki * n2), l4 = h3, a3 = Math.round((l4 + i.T) * s2);
          t2.fillStyle = e3.V;
          const o3 = Math.max(1, Math.floor(n2)), _3 = Math.floor(0.5 * n2);
          t2.fillRect(r4 - _3, l4, o3, a3 - l4);
        }
      }), t.useMediaCoordinateSpace(({ context: t2 }) => {
        const n2 = b(this.zt), e3 = 0 + i.C + i.T + i.L + i.P / 2;
        t2.font = i.R, t2.textAlign = "left", t2.textBaseline = "middle", t2.fillStyle = n2.V;
        const r3 = i.Wi.Mi(t2, "Apr0");
        t2.translate(a2 + s, e3 + r3), t2.fillText(n2.Kt, 0, 0);
      });
    }
  };
  var ht = class {
    constructor(t, i, n) {
      this.ft = true, this.Wt = new rt(), this.Ft = { yt: false, t: "#4c525e", V: "white", Kt: "", Hi: 0, ki: NaN, hi: true }, this.vt = t, this.$i = i, this.Ei = n;
    }
    bt() {
      this.ft = true;
    }
    gt() {
      return this.ft && (this.Mt(), this.ft = false), this.Wt.J(this.Ft), this.Wt;
    }
    Mt() {
      const t = this.Ft;
      if (t.yt = false, 2 === this.vt.W().mode)
        return;
      const i = this.vt.W().vertLine;
      if (!i.labelVisible)
        return;
      const n = this.$i.St();
      if (n.Ni())
        return;
      t.Hi = n.Hi();
      const s = this.Ei();
      if (null === s)
        return;
      t.ki = s.ki;
      const e2 = n.Ui(this.vt.xt());
      t.Kt = n.qi(b(e2)), t.yt = true;
      const r2 = R(i.labelBackgroundColor);
      t.t = r2.t, t.V = r2.i, t.hi = n.W().ticksVisible;
    }
  };
  var lt = class {
    constructor() {
      this.Yi = null, this.Zi = 0;
    }
    Xi() {
      return this.Zi;
    }
    Ki(t) {
      this.Zi = t;
    }
    Dt() {
      return this.Yi;
    }
    Gi(t) {
      this.Yi = t;
    }
    Ji(t) {
      return [];
    }
    Qi() {
      return [];
    }
    yt() {
      return true;
    }
  };
  var at;
  !function(t) {
    t[t.Normal = 0] = "Normal", t[t.Magnet = 1] = "Magnet", t[t.Hidden = 2] = "Hidden";
  }(at || (at = {}));
  var ot = class extends lt {
    constructor(t, i) {
      super(), this.tn = null, this.nn = NaN, this.sn = 0, this.en = true, this.rn = /* @__PURE__ */ new Map(), this.hn = false, this.ln = NaN, this.an = NaN, this._n = NaN, this.un = NaN, this.$i = t, this.cn = i, this.dn = new Y(t, this);
      this.fn = /* @__PURE__ */ ((t2, i2) => (n2) => {
        const s = i2(), e2 = t2();
        if (n2 === b(this.tn).vn())
          return { _t: e2, ki: s };
        {
          const t3 = b(n2.Ct());
          return { _t: n2.pn(s, t3), ki: s };
        }
      })(() => this.nn, () => this.an);
      const n = /* @__PURE__ */ ((t2, i2) => () => {
        const n2 = this.$i.St().mn(t2()), s = i2();
        return n2 && Number.isFinite(s) ? { ot: n2, ki: s } : null;
      })(() => this.sn, () => this.Yt());
      this.bn = new ht(this, t, n), this.wn = new X(this);
    }
    W() {
      return this.cn;
    }
    gn(t, i) {
      this._n = t, this.un = i;
    }
    Mn() {
      this._n = NaN, this.un = NaN;
    }
    xn() {
      return this._n;
    }
    Sn() {
      return this.un;
    }
    kn(t, i, n) {
      this.hn || (this.hn = true), this.en = true, this.yn(t, i, n);
    }
    xt() {
      return this.sn;
    }
    Yt() {
      return this.ln;
    }
    Zt() {
      return this.an;
    }
    yt() {
      return this.en;
    }
    Cn() {
      this.en = false, this.Tn(), this.nn = NaN, this.ln = NaN, this.an = NaN, this.tn = null, this.Mn();
    }
    Pn(t) {
      return null !== this.tn ? [this.wn, this.dn] : [];
    }
    Ut(t) {
      return t === this.tn && this.cn.horzLine.visible;
    }
    qt() {
      return this.cn.vertLine.visible;
    }
    Rn(t, i) {
      this.en && this.tn === t || this.rn.clear();
      const n = [];
      return this.tn === t && n.push(this.Dn(this.rn, i, this.fn)), n;
    }
    Qi() {
      return this.en ? [this.bn] : [];
    }
    Ht() {
      return this.tn;
    }
    Vn() {
      this.wn.bt(), this.rn.forEach((t) => t.bt()), this.bn.bt(), this.dn.bt();
    }
    On(t) {
      return t && !t.vn().Ni() ? t.vn() : null;
    }
    yn(t, i, n) {
      this.Bn(t, i, n) && this.Vn();
    }
    Bn(t, i, n) {
      const s = this.ln, e2 = this.an, r2 = this.nn, h2 = this.sn, l2 = this.tn, a2 = this.On(n);
      this.sn = t, this.ln = isNaN(t) ? NaN : this.$i.St().It(t), this.tn = n;
      const o2 = null !== a2 ? a2.Ct() : null;
      return null !== a2 && null !== o2 ? (this.nn = i, this.an = a2.Rt(i, o2)) : (this.nn = NaN, this.an = NaN), s !== this.ln || e2 !== this.an || h2 !== this.sn || r2 !== this.nn || l2 !== this.tn;
    }
    Tn() {
      const t = this.$i.wt().map((t2) => t2.In().An()).filter(L), i = 0 === t.length ? null : Math.max(...t);
      this.sn = null !== i ? i : NaN;
    }
    Dn(t, i, n) {
      let s = t.get(i);
      return void 0 === s && (s = new st(this, i, n), t.set(i, s)), s;
    }
  };
  function _t(t) {
    return "left" === t || "right" === t;
  }
  var ut = class _ut {
    constructor(t) {
      this.zn = /* @__PURE__ */ new Map(), this.Ln = [], this.En = t;
    }
    Nn(t, i) {
      const n = function(t2, i2) {
        return void 0 === t2 ? i2 : { Fn: Math.max(t2.Fn, i2.Fn), Wn: t2.Wn || i2.Wn };
      }(this.zn.get(t), i);
      this.zn.set(t, n);
    }
    jn() {
      return this.En;
    }
    Hn(t) {
      const i = this.zn.get(t);
      return void 0 === i ? { Fn: this.En } : { Fn: Math.max(this.En, i.Fn), Wn: i.Wn };
    }
    $n() {
      this.Un(), this.Ln = [{ qn: 0 }];
    }
    Yn(t) {
      this.Un(), this.Ln = [{ qn: 1, Vt: t }];
    }
    Zn(t) {
      this.Xn(), this.Ln.push({ qn: 5, Vt: t });
    }
    Un() {
      this.Xn(), this.Ln.push({ qn: 6 });
    }
    Kn() {
      this.Un(), this.Ln = [{ qn: 4 }];
    }
    Gn(t) {
      this.Un(), this.Ln.push({ qn: 2, Vt: t });
    }
    Jn(t) {
      this.Un(), this.Ln.push({ qn: 3, Vt: t });
    }
    Qn() {
      return this.Ln;
    }
    ts(t) {
      for (const i of t.Ln)
        this.ns(i);
      this.En = Math.max(this.En, t.En), t.zn.forEach((t2, i) => {
        this.Nn(i, t2);
      });
    }
    static ss() {
      return new _ut(2);
    }
    static es() {
      return new _ut(3);
    }
    ns(t) {
      switch (t.qn) {
        case 0:
          this.$n();
          break;
        case 1:
          this.Yn(t.Vt);
          break;
        case 2:
          this.Gn(t.Vt);
          break;
        case 3:
          this.Jn(t.Vt);
          break;
        case 4:
          this.Kn();
          break;
        case 5:
          this.Zn(t.Vt);
          break;
        case 6:
          this.Xn();
      }
    }
    Xn() {
      const t = this.Ln.findIndex((t2) => 5 === t2.qn);
      -1 !== t && this.Ln.splice(t, 1);
    }
  };
  var ct = ".";
  function dt(t, i) {
    if (!O(t))
      return "n/a";
    if (!B(i))
      throw new TypeError("invalid length");
    if (i < 0 || i > 16)
      throw new TypeError("invalid length");
    if (0 === i)
      return t.toString();
    return ("0000000000000000" + t.toString()).slice(-i);
  }
  var ft = class {
    constructor(t, i) {
      if (i || (i = 1), O(t) && B(t) || (t = 100), t < 0)
        throw new TypeError("invalid base");
      this.Li = t, this.rs = i, this.hs();
    }
    format(t) {
      const i = t < 0 ? "\u2212" : "";
      return t = Math.abs(t), i + this.ls(t);
    }
    hs() {
      if (this._s = 0, this.Li > 0 && this.rs > 0) {
        let t = this.Li;
        for (; t > 1; )
          t /= 10, this._s++;
      }
    }
    ls(t) {
      const i = this.Li / this.rs;
      let n = Math.floor(t), s = "";
      const e2 = void 0 !== this._s ? this._s : NaN;
      if (i > 1) {
        let r2 = +(Math.round(t * i) - n * i).toFixed(this._s);
        r2 >= i && (r2 -= i, n += 1), s = ct + dt(+r2.toFixed(this._s) * this.rs, e2);
      } else
        n = Math.round(n * i) / i, e2 > 0 && (s = ct + dt(0, e2));
      return n.toFixed(0) + s;
    }
  };
  var vt = class extends ft {
    constructor(t = 100) {
      super(t);
    }
    format(t) {
      return `${super.format(t)}%`;
    }
  };
  var pt = class {
    constructor(t) {
      this.us = t;
    }
    format(t) {
      let i = "";
      return t < 0 && (i = "-", t = -t), t < 995 ? i + this.cs(t) : t < 999995 ? i + this.cs(t / 1e3) + "K" : t < 999999995 ? (t = 1e3 * Math.round(t / 1e3), i + this.cs(t / 1e6) + "M") : (t = 1e6 * Math.round(t / 1e6), i + this.cs(t / 1e9) + "B");
    }
    cs(t) {
      let i;
      const n = Math.pow(10, this.us);
      return i = (t = Math.round(t * n) / n) >= 1e-15 && t < 1 ? t.toFixed(this.us).replace(/\.?0+$/, "") : String(t), i.replace(/(\.[1-9]*)0+$/, (t2, i2) => i2);
    }
  };
  function mt(t, i, n, s, e2, r2, h2) {
    if (0 === i.length || s.from >= i.length || s.to <= 0)
      return;
    const { context: l2, horizontalPixelRatio: a2, verticalPixelRatio: o2 } = t, _2 = i[s.from];
    let u2 = r2(t, _2), c2 = _2;
    if (s.to - s.from < 2) {
      const i2 = e2 / 2;
      l2.beginPath();
      const n2 = { nt: _2.nt - i2, st: _2.st }, s2 = { nt: _2.nt + i2, st: _2.st };
      l2.moveTo(n2.nt * a2, n2.st * o2), l2.lineTo(s2.nt * a2, s2.st * o2), h2(t, u2, n2, s2);
    } else {
      const e3 = (i2, n2) => {
        h2(t, u2, c2, n2), l2.beginPath(), u2 = i2, c2 = n2;
      };
      let d2 = c2;
      l2.beginPath(), l2.moveTo(_2.nt * a2, _2.st * o2);
      for (let h3 = s.from + 1; h3 < s.to; ++h3) {
        d2 = i[h3];
        const s2 = r2(t, d2);
        switch (n) {
          case 0:
            l2.lineTo(d2.nt * a2, d2.st * o2);
            break;
          case 1:
            l2.lineTo(d2.nt * a2, i[h3 - 1].st * o2), s2 !== u2 && (e3(s2, d2), l2.lineTo(d2.nt * a2, i[h3 - 1].st * o2)), l2.lineTo(d2.nt * a2, d2.st * o2);
            break;
          case 2: {
            const [t2, n2] = Mt(i, h3 - 1, h3);
            l2.bezierCurveTo(t2.nt * a2, t2.st * o2, n2.nt * a2, n2.st * o2, d2.nt * a2, d2.st * o2);
            break;
          }
        }
        1 !== n && s2 !== u2 && (e3(s2, d2), l2.moveTo(d2.nt * a2, d2.st * o2));
      }
      (c2 !== d2 || c2 === d2 && 1 === n) && h2(t, u2, c2, d2);
    }
  }
  var bt = 6;
  function wt(t, i) {
    return { nt: t.nt - i.nt, st: t.st - i.st };
  }
  function gt(t, i) {
    return { nt: t.nt / i, st: t.st / i };
  }
  function Mt(t, i, n) {
    const s = Math.max(0, i - 1), e2 = Math.min(t.length - 1, n + 1);
    var r2, h2;
    return [(r2 = t[i], h2 = gt(wt(t[n], t[s]), bt), { nt: r2.nt + h2.nt, st: r2.st + h2.st }), wt(t[n], gt(wt(t[e2], t[i]), bt))];
  }
  function xt(t, i, n, s, e2) {
    const { context: r2, horizontalPixelRatio: h2, verticalPixelRatio: l2 } = i;
    r2.lineTo(e2.nt * h2, t * l2), r2.lineTo(s.nt * h2, t * l2), r2.closePath(), r2.fillStyle = n, r2.fill();
  }
  var St = class extends H {
    constructor() {
      super(...arguments), this.G = null;
    }
    J(t) {
      this.G = t;
    }
    K(t) {
      var i;
      if (null === this.G)
        return;
      const { it: n, tt: s, ds: e2, et: r2, Nt: h2, fs: l2 } = this.G, a2 = null !== (i = this.G.vs) && void 0 !== i ? i : this.G.ps ? 0 : t.mediaSize.height;
      if (null === s)
        return;
      const o2 = t.context;
      o2.lineCap = "butt", o2.lineJoin = "round", o2.lineWidth = r2, f(o2, h2), o2.lineWidth = 1, mt(t, n, l2, s, e2, this.bs.bind(this), xt.bind(null, a2));
    }
  };
  function kt(t, i, n) {
    return Math.min(Math.max(t, i), n);
  }
  function yt(t, i, n) {
    return i - t <= n;
  }
  function Ct(t) {
    const i = Math.ceil(t);
    return i % 2 == 0 ? i - 1 : i;
  }
  var Tt = class {
    ws(t, i) {
      const n = this.gs, { Ms: s, xs: e2, Ss: r2, ks: h2, ys: l2, vs: a2 } = i;
      if (void 0 === this.Cs || void 0 === n || n.Ms !== s || n.xs !== e2 || n.Ss !== r2 || n.ks !== h2 || n.vs !== a2 || n.ys !== l2) {
        const n2 = t.context.createLinearGradient(0, 0, 0, l2);
        if (n2.addColorStop(0, s), null != a2) {
          const i2 = kt(a2 * t.verticalPixelRatio / l2, 0, 1);
          n2.addColorStop(i2, e2), n2.addColorStop(i2, r2);
        }
        n2.addColorStop(1, h2), this.Cs = n2, this.gs = i;
      }
      return this.Cs;
    }
  };
  var Pt = class extends St {
    constructor() {
      super(...arguments), this.Ts = new Tt();
    }
    bs(t, i) {
      return this.Ts.ws(t, { Ms: i.Ps, xs: "", Ss: "", ks: i.Rs, ys: t.bitmapSize.height });
    }
  };
  function Rt(t, i) {
    const n = t.context;
    n.strokeStyle = i, n.stroke();
  }
  var Dt = class extends H {
    constructor() {
      super(...arguments), this.G = null;
    }
    J(t) {
      this.G = t;
    }
    K(t) {
      if (null === this.G)
        return;
      const { it: i, tt: n, ds: s, fs: e2, et: r2, Nt: h2, Ds: l2 } = this.G;
      if (null === n)
        return;
      const a2 = t.context;
      a2.lineCap = "butt", a2.lineWidth = r2 * t.verticalPixelRatio, f(a2, h2), a2.lineJoin = "round";
      const o2 = this.Vs.bind(this);
      void 0 !== e2 && mt(t, i, e2, n, s, o2, Rt), l2 && function(t2, i2, n2, s2, e3) {
        const { horizontalPixelRatio: r3, verticalPixelRatio: h3, context: l3 } = t2;
        let a3 = null;
        const o3 = Math.max(1, Math.floor(r3)) % 2 / 2, _2 = n2 * h3 + o3;
        for (let n3 = s2.to - 1; n3 >= s2.from; --n3) {
          const s3 = i2[n3];
          if (s3) {
            const i3 = e3(t2, s3);
            i3 !== a3 && (l3.beginPath(), null !== a3 && l3.fill(), l3.fillStyle = i3, a3 = i3);
            const n4 = Math.round(s3.nt * r3) + o3, u2 = s3.st * h3;
            l3.moveTo(n4, u2), l3.arc(n4, u2, _2, 0, 2 * Math.PI);
          }
        }
        l3.fill();
      }(t, i, l2, n, o2);
    }
  };
  var Vt = class extends Dt {
    Vs(t, i) {
      return i.lt;
    }
  };
  function Ot(t, i, n, s, e2 = 0, r2 = i.length) {
    let h2 = r2 - e2;
    for (; 0 < h2; ) {
      const r3 = h2 >> 1, l2 = e2 + r3;
      s(i[l2], n) === t ? (e2 = l2 + 1, h2 -= r3 + 1) : h2 = r3;
    }
    return e2;
  }
  var Bt = Ot.bind(null, true);
  var At = Ot.bind(null, false);
  function It(t, i) {
    return t.ot < i;
  }
  function zt(t, i) {
    return i < t.ot;
  }
  function Lt(t, i, n) {
    const s = i.Os(), e2 = i.ui(), r2 = Bt(t, s, It), h2 = At(t, e2, zt);
    if (!n)
      return { from: r2, to: h2 };
    let l2 = r2, a2 = h2;
    return r2 > 0 && r2 < t.length && t[r2].ot >= s && (l2 = r2 - 1), h2 > 0 && h2 < t.length && t[h2 - 1].ot <= e2 && (a2 = h2 + 1), { from: l2, to: a2 };
  }
  var Et = class {
    constructor(t, i, n) {
      this.Bs = true, this.As = true, this.Is = true, this.zs = [], this.Ls = null, this.Es = t, this.Ns = i, this.Fs = n;
    }
    bt(t) {
      this.Bs = true, "data" === t && (this.As = true), "options" === t && (this.Is = true);
    }
    gt() {
      return this.Es.yt() ? (this.Ws(), null === this.Ls ? null : this.js) : null;
    }
    Hs() {
      this.zs = this.zs.map((t) => Object.assign(Object.assign({}, t), this.Es.Us().$s(t.ot)));
    }
    qs() {
      this.Ls = null;
    }
    Ws() {
      this.As && (this.Ys(), this.As = false), this.Is && (this.Hs(), this.Is = false), this.Bs && (this.Zs(), this.Bs = false);
    }
    Zs() {
      const t = this.Es.Dt(), i = this.Ns.St();
      if (this.qs(), i.Ni() || t.Ni())
        return;
      const n = i.Xs();
      if (null === n)
        return;
      if (0 === this.Es.In().Ks())
        return;
      const s = this.Es.Ct();
      null !== s && (this.Ls = Lt(this.zs, n, this.Fs), this.Gs(t, i, s.Vt), this.Js());
    }
  };
  var Nt = class extends Et {
    constructor(t, i) {
      super(t, i, true);
    }
    Gs(t, i, n) {
      i.Qs(this.zs, E(this.Ls)), t.te(this.zs, n, E(this.Ls));
    }
    ie(t, i) {
      return { ot: t, _t: i, nt: NaN, st: NaN };
    }
    Ys() {
      const t = this.Es.Us();
      this.zs = this.Es.In().ne().map((i) => {
        const n = i.Vt[3];
        return this.se(i.ee, n, t);
      });
    }
  };
  var Ft = class extends Nt {
    constructor(t, i) {
      super(t, i), this.js = new j(), this.re = new Pt(), this.he = new Vt(), this.js.Z([this.re, this.he]);
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.ie(t, i)), n.$s(t));
    }
    Js() {
      const t = this.Es.W();
      this.re.J({ fs: t.lineType, it: this.zs, Nt: t.lineStyle, et: t.lineWidth, vs: null, ps: t.invertFilledArea, tt: this.Ls, ds: this.Ns.St().le() }), this.he.J({ fs: t.lineVisible ? t.lineType : void 0, it: this.zs, Nt: t.lineStyle, et: t.lineWidth, tt: this.Ls, ds: this.Ns.St().le(), Ds: t.pointMarkersVisible ? t.pointMarkersRadius || t.lineWidth / 2 + 2 : void 0 });
    }
  };
  var Wt = class extends H {
    constructor() {
      super(...arguments), this.zt = null, this.ae = 0, this.oe = 0;
    }
    J(t) {
      this.zt = t;
    }
    K({ context: t, horizontalPixelRatio: i, verticalPixelRatio: n }) {
      if (null === this.zt || 0 === this.zt.In.length || null === this.zt.tt)
        return;
      if (this.ae = this._e(i), this.ae >= 2) {
        Math.max(1, Math.floor(i)) % 2 != this.ae % 2 && this.ae--;
      }
      this.oe = this.zt.ue ? Math.min(this.ae, Math.floor(i)) : this.ae;
      let s = null;
      const e2 = this.oe <= this.ae && this.zt.le >= Math.floor(1.5 * i);
      for (let r2 = this.zt.tt.from; r2 < this.zt.tt.to; ++r2) {
        const h2 = this.zt.In[r2];
        s !== h2.ce && (t.fillStyle = h2.ce, s = h2.ce);
        const l2 = Math.floor(0.5 * this.oe), a2 = Math.round(h2.nt * i), o2 = a2 - l2, _2 = this.oe, u2 = o2 + _2 - 1, c2 = Math.min(h2.de, h2.fe), d2 = Math.max(h2.de, h2.fe), f2 = Math.round(c2 * n) - l2, v2 = Math.round(d2 * n) + l2, p2 = Math.max(v2 - f2, this.oe);
        t.fillRect(o2, f2, _2, p2);
        const m2 = Math.ceil(1.5 * this.ae);
        if (e2) {
          if (this.zt.ve) {
            const i3 = a2 - m2;
            let s3 = Math.max(f2, Math.round(h2.pe * n) - l2), e4 = s3 + _2 - 1;
            e4 > f2 + p2 - 1 && (e4 = f2 + p2 - 1, s3 = e4 - _2 + 1), t.fillRect(i3, s3, o2 - i3, e4 - s3 + 1);
          }
          const i2 = a2 + m2;
          let s2 = Math.max(f2, Math.round(h2.me * n) - l2), e3 = s2 + _2 - 1;
          e3 > f2 + p2 - 1 && (e3 = f2 + p2 - 1, s2 = e3 - _2 + 1), t.fillRect(u2 + 1, s2, i2 - u2, e3 - s2 + 1);
        }
      }
    }
    _e(t) {
      const i = Math.floor(t);
      return Math.max(i, Math.floor(function(t2, i2) {
        return Math.floor(0.3 * t2 * i2);
      }(b(this.zt).le, t)));
    }
  };
  var jt = class extends Et {
    constructor(t, i) {
      super(t, i, false);
    }
    Gs(t, i, n) {
      i.Qs(this.zs, E(this.Ls)), t.be(this.zs, n, E(this.Ls));
    }
    we(t, i, n) {
      return { ot: t, ge: i.Vt[0], Me: i.Vt[1], xe: i.Vt[2], Se: i.Vt[3], nt: NaN, pe: NaN, de: NaN, fe: NaN, me: NaN };
    }
    Ys() {
      const t = this.Es.Us();
      this.zs = this.Es.In().ne().map((i) => this.se(i.ee, i, t));
    }
  };
  var Ht = class extends jt {
    constructor() {
      super(...arguments), this.js = new Wt();
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.we(t, i, n)), n.$s(t));
    }
    Js() {
      const t = this.Es.W();
      this.js.J({ In: this.zs, le: this.Ns.St().le(), ve: t.openVisible, ue: t.thinBars, tt: this.Ls });
    }
  };
  var $t = class extends St {
    constructor() {
      super(...arguments), this.Ts = new Tt();
    }
    bs(t, i) {
      const n = this.G;
      return this.Ts.ws(t, { Ms: i.ke, xs: i.ye, Ss: i.Ce, ks: i.Te, ys: t.bitmapSize.height, vs: n.vs });
    }
  };
  var Ut = class extends Dt {
    constructor() {
      super(...arguments), this.Pe = new Tt();
    }
    Vs(t, i) {
      const n = this.G;
      return this.Pe.ws(t, { Ms: i.Re, xs: i.Re, Ss: i.De, ks: i.De, ys: t.bitmapSize.height, vs: n.vs });
    }
  };
  var qt = class extends Nt {
    constructor(t, i) {
      super(t, i), this.js = new j(), this.Ve = new $t(), this.Oe = new Ut(), this.js.Z([this.Ve, this.Oe]);
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.ie(t, i)), n.$s(t));
    }
    Js() {
      const t = this.Es.Ct();
      if (null === t)
        return;
      const i = this.Es.W(), n = this.Es.Dt().Rt(i.baseValue.price, t.Vt), s = this.Ns.St().le();
      this.Ve.J({ it: this.zs, et: i.lineWidth, Nt: i.lineStyle, fs: i.lineType, vs: n, ps: false, tt: this.Ls, ds: s }), this.Oe.J({ it: this.zs, et: i.lineWidth, Nt: i.lineStyle, fs: i.lineVisible ? i.lineType : void 0, Ds: i.pointMarkersVisible ? i.pointMarkersRadius || i.lineWidth / 2 + 2 : void 0, vs: n, tt: this.Ls, ds: s });
    }
  };
  var Yt = class extends H {
    constructor() {
      super(...arguments), this.zt = null, this.ae = 0;
    }
    J(t) {
      this.zt = t;
    }
    K(t) {
      if (null === this.zt || 0 === this.zt.In.length || null === this.zt.tt)
        return;
      const { horizontalPixelRatio: i } = t;
      if (this.ae = function(t2, i2) {
        if (t2 >= 2.5 && t2 <= 4)
          return Math.floor(3 * i2);
        const n2 = 1 - 0.2 * Math.atan(Math.max(4, t2) - 4) / (0.5 * Math.PI), s2 = Math.floor(t2 * n2 * i2), e2 = Math.floor(t2 * i2), r2 = Math.min(s2, e2);
        return Math.max(Math.floor(i2), r2);
      }(this.zt.le, i), this.ae >= 2) {
        Math.floor(i) % 2 != this.ae % 2 && this.ae--;
      }
      const n = this.zt.In;
      this.zt.Be && this.Ae(t, n, this.zt.tt), this.zt._i && this.Ie(t, n, this.zt.tt);
      const s = this.ze(i);
      (!this.zt._i || this.ae > 2 * s) && this.Le(t, n, this.zt.tt);
    }
    Ae(t, i, n) {
      if (null === this.zt)
        return;
      const { context: s, horizontalPixelRatio: e2, verticalPixelRatio: r2 } = t;
      let h2 = "", l2 = Math.min(Math.floor(e2), Math.floor(this.zt.le * e2));
      l2 = Math.max(Math.floor(e2), Math.min(l2, this.ae));
      const a2 = Math.floor(0.5 * l2);
      let o2 = null;
      for (let t2 = n.from; t2 < n.to; t2++) {
        const n2 = i[t2];
        n2.Ee !== h2 && (s.fillStyle = n2.Ee, h2 = n2.Ee);
        const _2 = Math.round(Math.min(n2.pe, n2.me) * r2), u2 = Math.round(Math.max(n2.pe, n2.me) * r2), c2 = Math.round(n2.de * r2), d2 = Math.round(n2.fe * r2);
        let f2 = Math.round(e2 * n2.nt) - a2;
        const v2 = f2 + l2 - 1;
        null !== o2 && (f2 = Math.max(o2 + 1, f2), f2 = Math.min(f2, v2));
        const p2 = v2 - f2 + 1;
        s.fillRect(f2, c2, p2, _2 - c2), s.fillRect(f2, u2 + 1, p2, d2 - u2), o2 = v2;
      }
    }
    ze(t) {
      let i = Math.floor(1 * t);
      this.ae <= 2 * i && (i = Math.floor(0.5 * (this.ae - 1)));
      const n = Math.max(Math.floor(t), i);
      return this.ae <= 2 * n ? Math.max(Math.floor(t), Math.floor(1 * t)) : n;
    }
    Ie(t, i, n) {
      if (null === this.zt)
        return;
      const { context: s, horizontalPixelRatio: e2, verticalPixelRatio: r2 } = t;
      let h2 = "";
      const l2 = this.ze(e2);
      let a2 = null;
      for (let t2 = n.from; t2 < n.to; t2++) {
        const n2 = i[t2];
        n2.Ne !== h2 && (s.fillStyle = n2.Ne, h2 = n2.Ne);
        let o2 = Math.round(n2.nt * e2) - Math.floor(0.5 * this.ae);
        const _2 = o2 + this.ae - 1, u2 = Math.round(Math.min(n2.pe, n2.me) * r2), c2 = Math.round(Math.max(n2.pe, n2.me) * r2);
        if (null !== a2 && (o2 = Math.max(a2 + 1, o2), o2 = Math.min(o2, _2)), this.zt.le * e2 > 2 * l2)
          K(s, o2, u2, _2 - o2 + 1, c2 - u2 + 1, l2);
        else {
          const t3 = _2 - o2 + 1;
          s.fillRect(o2, u2, t3, c2 - u2 + 1);
        }
        a2 = _2;
      }
    }
    Le(t, i, n) {
      if (null === this.zt)
        return;
      const { context: s, horizontalPixelRatio: e2, verticalPixelRatio: r2 } = t;
      let h2 = "";
      const l2 = this.ze(e2);
      for (let t2 = n.from; t2 < n.to; t2++) {
        const n2 = i[t2];
        let a2 = Math.round(Math.min(n2.pe, n2.me) * r2), o2 = Math.round(Math.max(n2.pe, n2.me) * r2), _2 = Math.round(n2.nt * e2) - Math.floor(0.5 * this.ae), u2 = _2 + this.ae - 1;
        if (n2.ce !== h2) {
          const t3 = n2.ce;
          s.fillStyle = t3, h2 = t3;
        }
        this.zt._i && (_2 += l2, a2 += l2, u2 -= l2, o2 -= l2), a2 > o2 || s.fillRect(_2, a2, u2 - _2 + 1, o2 - a2 + 1);
      }
    }
  };
  var Zt = class extends jt {
    constructor() {
      super(...arguments), this.js = new Yt();
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.we(t, i, n)), n.$s(t));
    }
    Js() {
      const t = this.Es.W();
      this.js.J({ In: this.zs, le: this.Ns.St().le(), Be: t.wickVisible, _i: t.borderVisible, tt: this.Ls });
    }
  };
  var Xt = class {
    constructor(t, i) {
      this.Fe = t, this.Li = i;
    }
    X(t, i, n) {
      this.Fe.draw(t, this.Li, i, n);
    }
  };
  var Kt = class extends Et {
    constructor(t, i, n) {
      super(t, i, false), this.wn = n, this.js = new Xt(this.wn.renderer(), (i2) => {
        const n2 = t.Ct();
        return null === n2 ? null : t.Dt().Rt(i2, n2.Vt);
      });
    }
    We(t) {
      return this.wn.priceValueBuilder(t);
    }
    je(t) {
      return this.wn.isWhitespace(t);
    }
    Ys() {
      const t = this.Es.Us();
      this.zs = this.Es.In().ne().map((i) => Object.assign(Object.assign({ ot: i.ee, nt: NaN }, t.$s(i.ee)), { He: i.$e }));
    }
    Gs(t, i) {
      i.Qs(this.zs, E(this.Ls));
    }
    Js() {
      this.wn.update({ bars: this.zs.map(Gt), barSpacing: this.Ns.St().le(), visibleRange: this.Ls }, this.Es.W());
    }
  };
  function Gt(t) {
    return { x: t.nt, time: t.ot, originalData: t.He, barColor: t.ce };
  }
  var Jt = class extends H {
    constructor() {
      super(...arguments), this.zt = null, this.Ue = [];
    }
    J(t) {
      this.zt = t, this.Ue = [];
    }
    K({ context: t, horizontalPixelRatio: i, verticalPixelRatio: n }) {
      if (null === this.zt || 0 === this.zt.it.length || null === this.zt.tt)
        return;
      this.Ue.length || this.qe(i);
      const s = Math.max(1, Math.floor(n)), e2 = Math.round(this.zt.Ye * n) - Math.floor(s / 2), r2 = e2 + s;
      for (let i2 = this.zt.tt.from; i2 < this.zt.tt.to; i2++) {
        const h2 = this.zt.it[i2], l2 = this.Ue[i2 - this.zt.tt.from], a2 = Math.round(h2.st * n);
        let o2, _2;
        t.fillStyle = h2.ce, a2 <= e2 ? (o2 = a2, _2 = r2) : (o2 = e2, _2 = a2 - Math.floor(s / 2) + s), t.fillRect(l2.Os, o2, l2.ui - l2.Os + 1, _2 - o2);
      }
    }
    qe(t) {
      if (null === this.zt || 0 === this.zt.it.length || null === this.zt.tt)
        return void (this.Ue = []);
      const i = Math.ceil(this.zt.le * t) <= 1 ? 0 : Math.max(1, Math.floor(t)), n = Math.round(this.zt.le * t) - i;
      this.Ue = new Array(this.zt.tt.to - this.zt.tt.from);
      for (let i2 = this.zt.tt.from; i2 < this.zt.tt.to; i2++) {
        const s2 = this.zt.it[i2], e2 = Math.round(s2.nt * t);
        let r2, h2;
        if (n % 2) {
          const t2 = (n - 1) / 2;
          r2 = e2 - t2, h2 = e2 + t2;
        } else {
          const t2 = n / 2;
          r2 = e2 - t2, h2 = e2 + t2 - 1;
        }
        this.Ue[i2 - this.zt.tt.from] = { Os: r2, ui: h2, Ze: e2, Xe: s2.nt * t, ot: s2.ot };
      }
      for (let t2 = this.zt.tt.from + 1; t2 < this.zt.tt.to; t2++) {
        const n2 = this.Ue[t2 - this.zt.tt.from], s2 = this.Ue[t2 - this.zt.tt.from - 1];
        n2.ot === s2.ot + 1 && (n2.Os - s2.ui !== i + 1 && (s2.Ze > s2.Xe ? s2.ui = n2.Os - i - 1 : n2.Os = s2.ui + i + 1));
      }
      let s = Math.ceil(this.zt.le * t);
      for (let t2 = this.zt.tt.from; t2 < this.zt.tt.to; t2++) {
        const i2 = this.Ue[t2 - this.zt.tt.from];
        i2.ui < i2.Os && (i2.ui = i2.Os);
        const n2 = i2.ui - i2.Os + 1;
        s = Math.min(n2, s);
      }
      if (i > 0 && s < 4)
        for (let t2 = this.zt.tt.from; t2 < this.zt.tt.to; t2++) {
          const i2 = this.Ue[t2 - this.zt.tt.from];
          i2.ui - i2.Os + 1 > s && (i2.Ze > i2.Xe ? i2.ui -= 1 : i2.Os += 1);
        }
    }
  };
  var Qt = class extends Nt {
    constructor() {
      super(...arguments), this.js = new Jt();
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.ie(t, i)), n.$s(t));
    }
    Js() {
      const t = { it: this.zs, le: this.Ns.St().le(), tt: this.Ls, Ye: this.Es.Dt().Rt(this.Es.W().base, b(this.Es.Ct()).Vt) };
      this.js.J(t);
    }
  };
  var ti = class extends Nt {
    constructor() {
      super(...arguments), this.js = new Vt();
    }
    se(t, i, n) {
      return Object.assign(Object.assign({}, this.ie(t, i)), n.$s(t));
    }
    Js() {
      const t = this.Es.W(), i = { it: this.zs, Nt: t.lineStyle, fs: t.lineVisible ? t.lineType : void 0, et: t.lineWidth, Ds: t.pointMarkersVisible ? t.pointMarkersRadius || t.lineWidth / 2 + 2 : void 0, tt: this.Ls, ds: this.Ns.St().le() };
      this.js.J(i);
    }
  };
  var ii = /[2-9]/g;
  var ni = class {
    constructor(t = 50) {
      this.Ke = 0, this.Ge = 1, this.Je = 1, this.Qe = {}, this.tr = /* @__PURE__ */ new Map(), this.ir = t;
    }
    nr() {
      this.Ke = 0, this.tr.clear(), this.Ge = 1, this.Je = 1, this.Qe = {};
    }
    xi(t, i, n) {
      return this.sr(t, i, n).width;
    }
    Mi(t, i, n) {
      const s = this.sr(t, i, n);
      return ((s.actualBoundingBoxAscent || 0) - (s.actualBoundingBoxDescent || 0)) / 2;
    }
    sr(t, i, n) {
      const s = n || ii, e2 = String(i).replace(s, "0");
      if (this.tr.has(e2))
        return m(this.tr.get(e2)).er;
      if (this.Ke === this.ir) {
        const t2 = this.Qe[this.Je];
        delete this.Qe[this.Je], this.tr.delete(t2), this.Je++, this.Ke--;
      }
      t.save(), t.textBaseline = "middle";
      const r2 = t.measureText(e2);
      return t.restore(), 0 === r2.width && i.length || (this.tr.set(e2, { er: r2, rr: this.Ge }), this.Qe[this.Ge] = e2, this.Ke++, this.Ge++), r2;
    }
  };
  var si = class {
    constructor(t) {
      this.hr = null, this.k = null, this.lr = "right", this.ar = t;
    }
    _r(t, i, n) {
      this.hr = t, this.k = i, this.lr = n;
    }
    X(t) {
      null !== this.k && null !== this.hr && this.hr.X(t, this.k, this.ar, this.lr);
    }
  };
  var ei = class {
    constructor(t, i, n) {
      this.ur = t, this.ar = new ni(50), this.cr = i, this.F = n, this.j = -1, this.Wt = new si(this.ar);
    }
    gt() {
      const t = this.F.dr(this.cr);
      if (null === t)
        return null;
      const i = t.vr(this.cr) ? t.pr() : this.cr.Dt();
      if (null === i)
        return null;
      const n = t.mr(i);
      if ("overlay" === n)
        return null;
      const s = this.F.br();
      return s.P !== this.j && (this.j = s.P, this.ar.nr()), this.Wt._r(this.ur.Ii(), s, n), this.Wt;
    }
  };
  var ri = class extends H {
    constructor() {
      super(...arguments), this.zt = null;
    }
    J(t) {
      this.zt = t;
    }
    wr(t, i) {
      var n;
      if (!(null === (n = this.zt) || void 0 === n ? void 0 : n.yt))
        return null;
      const { st: s, et: e2, gr: r2 } = this.zt;
      return i >= s - e2 - 7 && i <= s + e2 + 7 ? { Mr: this.zt, gr: r2 } : null;
    }
    K({ context: t, bitmapSize: i, horizontalPixelRatio: n, verticalPixelRatio: s }) {
      if (null === this.zt)
        return;
      if (false === this.zt.yt)
        return;
      const e2 = Math.round(this.zt.st * s);
      e2 < 0 || e2 > i.height || (t.lineCap = "butt", t.strokeStyle = this.zt.V, t.lineWidth = Math.floor(this.zt.et * n), f(t, this.zt.Nt), v(t, e2, 0, i.width));
    }
  };
  var hi = class {
    constructor(t) {
      this.Sr = { st: 0, V: "rgba(0, 0, 0, 0)", et: 1, Nt: 0, yt: false }, this.kr = new ri(), this.ft = true, this.Es = t, this.Ns = t.$t(), this.kr.J(this.Sr);
    }
    bt() {
      this.ft = true;
    }
    gt() {
      return this.Es.yt() ? (this.ft && (this.yr(), this.ft = false), this.kr) : null;
    }
  };
  var li = class extends hi {
    constructor(t) {
      super(t);
    }
    yr() {
      this.Sr.yt = false;
      const t = this.Es.Dt(), i = t.Cr().Cr;
      if (2 !== i && 3 !== i)
        return;
      const n = this.Es.W();
      if (!n.baseLineVisible || !this.Es.yt())
        return;
      const s = this.Es.Ct();
      null !== s && (this.Sr.yt = true, this.Sr.st = t.Rt(s.Vt, s.Vt), this.Sr.V = n.baseLineColor, this.Sr.et = n.baseLineWidth, this.Sr.Nt = n.baseLineStyle);
    }
  };
  var ai = class extends H {
    constructor() {
      super(...arguments), this.zt = null;
    }
    J(t) {
      this.zt = t;
    }
    $e() {
      return this.zt;
    }
    K({ context: t, horizontalPixelRatio: i, verticalPixelRatio: n }) {
      const s = this.zt;
      if (null === s)
        return;
      const e2 = Math.max(1, Math.floor(i)), r2 = e2 % 2 / 2, h2 = Math.round(s.Xe.x * i) + r2, l2 = s.Xe.y * n;
      t.fillStyle = s.Tr, t.beginPath();
      const a2 = Math.max(2, 1.5 * s.Pr) * i;
      t.arc(h2, l2, a2, 0, 2 * Math.PI, false), t.fill(), t.fillStyle = s.Rr, t.beginPath(), t.arc(h2, l2, s.ht * i, 0, 2 * Math.PI, false), t.fill(), t.lineWidth = e2, t.strokeStyle = s.Dr, t.beginPath(), t.arc(h2, l2, s.ht * i + e2 / 2, 0, 2 * Math.PI, false), t.stroke();
    }
  };
  var oi = [{ Vr: 0, Or: 0.25, Br: 4, Ar: 10, Ir: 0.25, zr: 0, Lr: 0.4, Er: 0.8 }, { Vr: 0.25, Or: 0.525, Br: 10, Ar: 14, Ir: 0, zr: 0, Lr: 0.8, Er: 0 }, { Vr: 0.525, Or: 1, Br: 14, Ar: 14, Ir: 0, zr: 0, Lr: 0, Er: 0 }];
  function _i(t, i, n, s) {
    return function(t2, i2) {
      if ("transparent" === t2)
        return t2;
      const n2 = T(t2), s2 = n2[3];
      return `rgba(${n2[0]}, ${n2[1]}, ${n2[2]}, ${i2 * s2})`;
    }(t, n + (s - n) * i);
  }
  function ui(t, i) {
    const n = t % 2600 / 2600;
    let s;
    for (const t2 of oi)
      if (n >= t2.Vr && n <= t2.Or) {
        s = t2;
        break;
      }
    p(void 0 !== s, "Last price animation internal logic error");
    const e2 = (n - s.Vr) / (s.Or - s.Vr);
    return { Rr: _i(i, e2, s.Ir, s.zr), Dr: _i(i, e2, s.Lr, s.Er), ht: (r2 = e2, h2 = s.Br, l2 = s.Ar, h2 + (l2 - h2) * r2) };
    var r2, h2, l2;
  }
  var ci = class {
    constructor(t) {
      this.Wt = new ai(), this.ft = true, this.Nr = true, this.Fr = performance.now(), this.Wr = this.Fr - 1, this.jr = t;
    }
    Hr() {
      this.Wr = this.Fr - 1, this.bt();
    }
    $r() {
      if (this.bt(), 2 === this.jr.W().lastPriceAnimation) {
        const t = performance.now(), i = this.Wr - t;
        if (i > 0)
          return void (i < 650 && (this.Wr += 2600));
        this.Fr = t, this.Wr = t + 2600;
      }
    }
    bt() {
      this.ft = true;
    }
    Ur() {
      this.Nr = true;
    }
    yt() {
      return 0 !== this.jr.W().lastPriceAnimation;
    }
    qr() {
      switch (this.jr.W().lastPriceAnimation) {
        case 0:
          return false;
        case 1:
          return true;
        case 2:
          return performance.now() <= this.Wr;
      }
    }
    gt() {
      return this.ft ? (this.Mt(), this.ft = false, this.Nr = false) : this.Nr && (this.Yr(), this.Nr = false), this.Wt;
    }
    Mt() {
      this.Wt.J(null);
      const t = this.jr.$t().St(), i = t.Xs(), n = this.jr.Ct();
      if (null === i || null === n)
        return;
      const s = this.jr.Zr(true);
      if (s.Xr || !i.Kr(s.ee))
        return;
      const e2 = { x: t.It(s.ee), y: this.jr.Dt().Rt(s._t, n.Vt) }, r2 = s.V, h2 = this.jr.W().lineWidth, l2 = ui(this.Gr(), r2);
      this.Wt.J({ Tr: r2, Pr: h2, Rr: l2.Rr, Dr: l2.Dr, ht: l2.ht, Xe: e2 });
    }
    Yr() {
      const t = this.Wt.$e();
      if (null !== t) {
        const i = ui(this.Gr(), t.Tr);
        t.Rr = i.Rr, t.Dr = i.Dr, t.ht = i.ht;
      }
    }
    Gr() {
      return this.qr() ? performance.now() - this.Fr : 2599;
    }
  };
  function di(t, i) {
    return Ct(Math.min(Math.max(t, 12), 30) * i);
  }
  function fi(t, i) {
    switch (t) {
      case "arrowDown":
      case "arrowUp":
        return di(i, 1);
      case "circle":
        return di(i, 0.8);
      case "square":
        return di(i, 0.7);
    }
  }
  function vi(t) {
    return function(t2) {
      const i = Math.ceil(t2);
      return i % 2 != 0 ? i - 1 : i;
    }(di(t, 1));
  }
  function pi(t) {
    return Math.max(di(t, 0.1), 3);
  }
  function mi(t, i, n) {
    return i ? t : n ? Math.ceil(t / 2) : 0;
  }
  function bi(t, i, n, s, e2) {
    const r2 = fi("square", n), h2 = (r2 - 1) / 2, l2 = t - h2, a2 = i - h2;
    return s >= l2 && s <= l2 + r2 && e2 >= a2 && e2 <= a2 + r2;
  }
  function wi(t, i, n, s) {
    const e2 = (fi("arrowUp", s) - 1) / 2 * n.Jr, r2 = (Ct(s / 2) - 1) / 2 * n.Jr;
    i.beginPath(), t ? (i.moveTo(n.nt - e2, n.st), i.lineTo(n.nt, n.st - e2), i.lineTo(n.nt + e2, n.st), i.lineTo(n.nt + r2, n.st), i.lineTo(n.nt + r2, n.st + e2), i.lineTo(n.nt - r2, n.st + e2), i.lineTo(n.nt - r2, n.st)) : (i.moveTo(n.nt - e2, n.st), i.lineTo(n.nt, n.st + e2), i.lineTo(n.nt + e2, n.st), i.lineTo(n.nt + r2, n.st), i.lineTo(n.nt + r2, n.st - e2), i.lineTo(n.nt - r2, n.st - e2), i.lineTo(n.nt - r2, n.st)), i.fill();
  }
  function gi(t, i, n, s, e2, r2) {
    return bi(i, n, s, e2, r2);
  }
  var Mi = class extends H {
    constructor() {
      super(...arguments), this.zt = null, this.ar = new ni(), this.j = -1, this.H = "", this.Qr = "";
    }
    J(t) {
      this.zt = t;
    }
    _r(t, i) {
      this.j === t && this.H === i || (this.j = t, this.H = i, this.Qr = F(t, i), this.ar.nr());
    }
    wr(t, i) {
      if (null === this.zt || null === this.zt.tt)
        return null;
      for (let n = this.zt.tt.from; n < this.zt.tt.to; n++) {
        const s = this.zt.it[n];
        if (Si(s, t, i))
          return { Mr: s.th, gr: s.gr };
      }
      return null;
    }
    K({ context: t, horizontalPixelRatio: i, verticalPixelRatio: n }, s, e2) {
      if (null !== this.zt && null !== this.zt.tt) {
        t.textBaseline = "middle", t.font = this.Qr;
        for (let s2 = this.zt.tt.from; s2 < this.zt.tt.to; s2++) {
          const e3 = this.zt.it[s2];
          void 0 !== e3.Kt && (e3.Kt.Hi = this.ar.xi(t, e3.Kt.ih), e3.Kt.At = this.j, e3.Kt.nt = e3.nt - e3.Kt.Hi / 2), xi(e3, t, i, n);
        }
      }
    }
  };
  function xi(t, i, n, s) {
    i.fillStyle = t.V, void 0 !== t.Kt && function(t2, i2, n2, s2, e2, r2) {
      t2.save(), t2.scale(e2, r2), t2.fillText(i2, n2, s2), t2.restore();
    }(i, t.Kt.ih, t.Kt.nt, t.Kt.st, n, s), function(t2, i2, n2) {
      if (0 === t2.Ks)
        return;
      switch (t2.nh) {
        case "arrowDown":
          return void wi(false, i2, n2, t2.Ks);
        case "arrowUp":
          return void wi(true, i2, n2, t2.Ks);
        case "circle":
          return void function(t3, i3, n3) {
            const s2 = (fi("circle", n3) - 1) / 2;
            t3.beginPath(), t3.arc(i3.nt, i3.st, s2 * i3.Jr, 0, 2 * Math.PI, false), t3.fill();
          }(i2, n2, t2.Ks);
        case "square":
          return void function(t3, i3, n3) {
            const s2 = fi("square", n3), e2 = (s2 - 1) * i3.Jr / 2, r2 = i3.nt - e2, h2 = i3.st - e2;
            t3.fillRect(r2, h2, s2 * i3.Jr, s2 * i3.Jr);
          }(i2, n2, t2.Ks);
      }
      t2.nh;
    }(t, i, function(t2, i2, n2) {
      const s2 = Math.max(1, Math.floor(i2)) % 2 / 2;
      return { nt: Math.round(t2.nt * i2) + s2, st: t2.st * n2, Jr: i2 };
    }(t, n, s));
  }
  function Si(t, i, n) {
    return !(void 0 === t.Kt || !function(t2, i2, n2, s, e2, r2) {
      const h2 = s / 2;
      return e2 >= t2 && e2 <= t2 + n2 && r2 >= i2 - h2 && r2 <= i2 + h2;
    }(t.Kt.nt, t.Kt.st, t.Kt.Hi, t.Kt.At, i, n)) || function(t2, i2, n2) {
      if (0 === t2.Ks)
        return false;
      switch (t2.nh) {
        case "arrowDown":
        case "arrowUp":
          return gi(0, t2.nt, t2.st, t2.Ks, i2, n2);
        case "circle":
          return function(t3, i3, n3, s, e2) {
            const r2 = 2 + fi("circle", n3) / 2, h2 = t3 - s, l2 = i3 - e2;
            return Math.sqrt(h2 * h2 + l2 * l2) <= r2;
          }(t2.nt, t2.st, t2.Ks, i2, n2);
        case "square":
          return bi(t2.nt, t2.st, t2.Ks, i2, n2);
      }
    }(t, i, n);
  }
  function ki(t, i, n, s, e2, r2, h2, l2, a2) {
    const o2 = O(n) ? n : n.Se, _2 = O(n) ? n : n.Me, u2 = O(n) ? n : n.xe, c2 = O(i.size) ? Math.max(i.size, 0) : 1, d2 = vi(l2.le()) * c2, f2 = d2 / 2;
    switch (t.Ks = d2, i.position) {
      case "inBar":
        return t.st = h2.Rt(o2, a2), void (void 0 !== t.Kt && (t.Kt.st = t.st + f2 + r2 + 0.6 * e2));
      case "aboveBar":
        return t.st = h2.Rt(_2, a2) - f2 - s.sh, void 0 !== t.Kt && (t.Kt.st = t.st - f2 - 0.6 * e2, s.sh += 1.2 * e2), void (s.sh += d2 + r2);
      case "belowBar":
        return t.st = h2.Rt(u2, a2) + f2 + s.eh, void 0 !== t.Kt && (t.Kt.st = t.st + f2 + r2 + 0.6 * e2, s.eh += 1.2 * e2), void (s.eh += d2 + r2);
    }
    i.position;
  }
  var yi = class {
    constructor(t, i) {
      this.ft = true, this.rh = true, this.hh = true, this.ah = null, this.oh = null, this.Wt = new Mi(), this.jr = t, this.$i = i, this.zt = { it: [], tt: null };
    }
    bt(t) {
      this.ft = true, this.hh = true, "data" === t && (this.rh = true, this.oh = null);
    }
    gt(t) {
      if (!this.jr.yt())
        return null;
      this.ft && this._h();
      const i = this.$i.W().layout;
      return this.Wt._r(i.fontSize, i.fontFamily), this.Wt.J(this.zt), this.Wt;
    }
    uh() {
      if (this.hh) {
        if (this.jr.dh().length > 0) {
          const t = this.$i.St().le(), i = pi(t), n = 1.5 * vi(t) + 2 * i, s = this.fh();
          this.ah = { above: mi(n, s.aboveBar, s.inBar), below: mi(n, s.belowBar, s.inBar) };
        } else
          this.ah = null;
        this.hh = false;
      }
      return this.ah;
    }
    fh() {
      return null === this.oh && (this.oh = this.jr.dh().reduce((t, i) => (t[i.position] || (t[i.position] = true), t), { inBar: false, aboveBar: false, belowBar: false })), this.oh;
    }
    _h() {
      const t = this.jr.Dt(), i = this.$i.St(), n = this.jr.dh();
      this.rh && (this.zt.it = n.map((t2) => ({ ot: t2.time, nt: 0, st: 0, Ks: 0, nh: t2.shape, V: t2.color, th: t2.th, gr: t2.id, Kt: void 0 })), this.rh = false);
      const s = this.$i.W().layout;
      this.zt.tt = null;
      const e2 = i.Xs();
      if (null === e2)
        return;
      const r2 = this.jr.Ct();
      if (null === r2)
        return;
      if (0 === this.zt.it.length)
        return;
      let h2 = NaN;
      const l2 = pi(i.le()), a2 = { sh: l2, eh: l2 };
      this.zt.tt = Lt(this.zt.it, e2, true);
      for (let e3 = this.zt.tt.from; e3 < this.zt.tt.to; e3++) {
        const o2 = n[e3];
        o2.time !== h2 && (a2.sh = l2, a2.eh = l2, h2 = o2.time);
        const _2 = this.zt.it[e3];
        _2.nt = i.It(o2.time), void 0 !== o2.text && o2.text.length > 0 && (_2.Kt = { ih: o2.text, nt: 0, st: 0, Hi: 0, At: 0 });
        const u2 = this.jr.ph(o2.time);
        null !== u2 && ki(_2, o2, u2, a2, s.fontSize, l2, t, i, r2.Vt);
      }
      this.ft = false;
    }
  };
  var Ci = class extends hi {
    constructor(t) {
      super(t);
    }
    yr() {
      const t = this.Sr;
      t.yt = false;
      const i = this.Es.W();
      if (!i.priceLineVisible || !this.Es.yt())
        return;
      const n = this.Es.Zr(0 === i.priceLineSource);
      n.Xr || (t.yt = true, t.st = n.ki, t.V = this.Es.mh(n.V), t.et = i.priceLineWidth, t.Nt = i.priceLineStyle);
    }
  };
  var Ti = class extends nt {
    constructor(t) {
      super(), this.jt = t;
    }
    zi(t, i, n) {
      t.yt = false, i.yt = false;
      const s = this.jt;
      if (!s.yt())
        return;
      const e2 = s.W(), r2 = e2.lastValueVisible, h2 = "" !== s.bh(), l2 = 0 === e2.seriesLastValueMode, a2 = s.Zr(false);
      if (a2.Xr)
        return;
      r2 && (t.Kt = this.wh(a2, r2, l2), t.yt = 0 !== t.Kt.length), (h2 || l2) && (i.Kt = this.gh(a2, r2, h2, l2), i.yt = i.Kt.length > 0);
      const o2 = s.mh(a2.V), _2 = R(o2);
      n.t = _2.t, n.ki = a2.ki, i.Ot = s.$t().Bt(a2.ki / s.Dt().At()), t.Ot = o2, t.V = _2.i, i.V = _2.i;
    }
    gh(t, i, n, s) {
      let e2 = "";
      const r2 = this.jt.bh();
      return n && 0 !== r2.length && (e2 += `${r2} `), i && s && (e2 += this.jt.Dt().Mh() ? t.xh : t.Sh), e2.trim();
    }
    wh(t, i, n) {
      return i ? n ? this.jt.Dt().Mh() ? t.Sh : t.xh : t.Kt : "";
    }
  };
  function Pi(t, i, n, s) {
    const e2 = Number.isFinite(i), r2 = Number.isFinite(n);
    return e2 && r2 ? t(i, n) : e2 || r2 ? e2 ? i : n : s;
  }
  var Ri = class _Ri {
    constructor(t, i) {
      this.kh = t, this.yh = i;
    }
    Ch(t) {
      return null !== t && (this.kh === t.kh && this.yh === t.yh);
    }
    Th() {
      return new _Ri(this.kh, this.yh);
    }
    Ph() {
      return this.kh;
    }
    Rh() {
      return this.yh;
    }
    Dh() {
      return this.yh - this.kh;
    }
    Ni() {
      return this.yh === this.kh || Number.isNaN(this.yh) || Number.isNaN(this.kh);
    }
    ts(t) {
      return null === t ? this : new _Ri(Pi(Math.min, this.Ph(), t.Ph(), -1 / 0), Pi(Math.max, this.Rh(), t.Rh(), 1 / 0));
    }
    Vh(t) {
      if (!O(t))
        return;
      if (0 === this.yh - this.kh)
        return;
      const i = 0.5 * (this.yh + this.kh);
      let n = this.yh - i, s = this.kh - i;
      n *= t, s *= t, this.yh = i + n, this.kh = i + s;
    }
    Oh(t) {
      O(t) && (this.yh += t, this.kh += t);
    }
    Bh() {
      return { minValue: this.kh, maxValue: this.yh };
    }
    static Ah(t) {
      return null === t ? null : new _Ri(t.minValue, t.maxValue);
    }
  };
  var Di = class _Di {
    constructor(t, i) {
      this.Ih = t, this.zh = i || null;
    }
    Lh() {
      return this.Ih;
    }
    Eh() {
      return this.zh;
    }
    Bh() {
      return null === this.Ih ? null : { priceRange: this.Ih.Bh(), margins: this.zh || void 0 };
    }
    static Ah(t) {
      return null === t ? null : new _Di(Ri.Ah(t.priceRange), t.margins);
    }
  };
  var Vi = class extends hi {
    constructor(t, i) {
      super(t), this.Nh = i;
    }
    yr() {
      const t = this.Sr;
      t.yt = false;
      const i = this.Nh.W();
      if (!this.Es.yt() || !i.lineVisible)
        return;
      const n = this.Nh.Fh();
      null !== n && (t.yt = true, t.st = n, t.V = i.color, t.et = i.lineWidth, t.Nt = i.lineStyle, t.gr = this.Nh.W().id);
    }
  };
  var Oi = class extends nt {
    constructor(t, i) {
      super(), this.jr = t, this.Nh = i;
    }
    zi(t, i, n) {
      t.yt = false, i.yt = false;
      const s = this.Nh.W(), e2 = s.axisLabelVisible, r2 = "" !== s.title, h2 = this.jr;
      if (!e2 || !h2.yt())
        return;
      const l2 = this.Nh.Fh();
      if (null === l2)
        return;
      r2 && (i.Kt = s.title, i.yt = true), i.Ot = h2.$t().Bt(l2 / h2.Dt().At()), t.Kt = this.Wh(s.price), t.yt = true;
      const a2 = R(s.axisLabelColor || s.color);
      n.t = a2.t;
      const o2 = s.axisLabelTextColor || a2.i;
      t.V = o2, i.V = o2, n.ki = l2;
    }
    Wh(t) {
      const i = this.jr.Ct();
      return null === i ? "" : this.jr.Dt().Fi(t, i.Vt);
    }
  };
  var Bi = class {
    constructor(t, i) {
      this.jr = t, this.cn = i, this.jh = new Vi(t, this), this.ur = new Oi(t, this), this.Hh = new ei(this.ur, t, t.$t());
    }
    $h(t) {
      V(this.cn, t), this.bt(), this.jr.$t().Uh();
    }
    W() {
      return this.cn;
    }
    qh() {
      return this.jh;
    }
    Yh() {
      return this.Hh;
    }
    Zh() {
      return this.ur;
    }
    bt() {
      this.jh.bt(), this.ur.bt();
    }
    Fh() {
      const t = this.jr, i = t.Dt();
      if (t.$t().St().Ni() || i.Ni())
        return null;
      const n = t.Ct();
      return null === n ? null : i.Rt(this.cn.price, n.Vt);
    }
  };
  var Ai = class extends lt {
    constructor(t) {
      super(), this.$i = t;
    }
    $t() {
      return this.$i;
    }
  };
  var Ii = { Bar: (t, i, n, s) => {
    var e2;
    const r2 = i.upColor, h2 = i.downColor, l2 = b(t(n, s)), a2 = w(l2.Vt[0]) <= w(l2.Vt[3]);
    return { ce: null !== (e2 = l2.V) && void 0 !== e2 ? e2 : a2 ? r2 : h2 };
  }, Candlestick: (t, i, n, s) => {
    var e2, r2, h2;
    const l2 = i.upColor, a2 = i.downColor, o2 = i.borderUpColor, _2 = i.borderDownColor, u2 = i.wickUpColor, c2 = i.wickDownColor, d2 = b(t(n, s)), f2 = w(d2.Vt[0]) <= w(d2.Vt[3]);
    return { ce: null !== (e2 = d2.V) && void 0 !== e2 ? e2 : f2 ? l2 : a2, Ne: null !== (r2 = d2.Ot) && void 0 !== r2 ? r2 : f2 ? o2 : _2, Ee: null !== (h2 = d2.Xh) && void 0 !== h2 ? h2 : f2 ? u2 : c2 };
  }, Custom: (t, i, n, s) => {
    var e2;
    return { ce: null !== (e2 = b(t(n, s)).V) && void 0 !== e2 ? e2 : i.color };
  }, Area: (t, i, n, s) => {
    var e2, r2, h2, l2;
    const a2 = b(t(n, s));
    return { ce: null !== (e2 = a2.lt) && void 0 !== e2 ? e2 : i.lineColor, lt: null !== (r2 = a2.lt) && void 0 !== r2 ? r2 : i.lineColor, Ps: null !== (h2 = a2.Ps) && void 0 !== h2 ? h2 : i.topColor, Rs: null !== (l2 = a2.Rs) && void 0 !== l2 ? l2 : i.bottomColor };
  }, Baseline: (t, i, n, s) => {
    var e2, r2, h2, l2, a2, o2;
    const _2 = b(t(n, s));
    return { ce: _2.Vt[3] >= i.baseValue.price ? i.topLineColor : i.bottomLineColor, Re: null !== (e2 = _2.Re) && void 0 !== e2 ? e2 : i.topLineColor, De: null !== (r2 = _2.De) && void 0 !== r2 ? r2 : i.bottomLineColor, ke: null !== (h2 = _2.ke) && void 0 !== h2 ? h2 : i.topFillColor1, ye: null !== (l2 = _2.ye) && void 0 !== l2 ? l2 : i.topFillColor2, Ce: null !== (a2 = _2.Ce) && void 0 !== a2 ? a2 : i.bottomFillColor1, Te: null !== (o2 = _2.Te) && void 0 !== o2 ? o2 : i.bottomFillColor2 };
  }, Line: (t, i, n, s) => {
    var e2, r2;
    const h2 = b(t(n, s));
    return { ce: null !== (e2 = h2.V) && void 0 !== e2 ? e2 : i.color, lt: null !== (r2 = h2.V) && void 0 !== r2 ? r2 : i.color };
  }, Histogram: (t, i, n, s) => {
    var e2;
    return { ce: null !== (e2 = b(t(n, s)).V) && void 0 !== e2 ? e2 : i.color };
  } };
  var zi = class {
    constructor(t) {
      this.Kh = (t2, i) => void 0 !== i ? i.Vt : this.jr.In().Gh(t2), this.jr = t, this.Jh = Ii[t.Qh()];
    }
    $s(t, i) {
      return this.Jh(this.Kh, this.jr.W(), t, i);
    }
  };
  var Li;
  !function(t) {
    t[t.NearestLeft = -1] = "NearestLeft", t[t.None = 0] = "None", t[t.NearestRight = 1] = "NearestRight";
  }(Li || (Li = {}));
  var Ei = 30;
  var Ni = class {
    constructor() {
      this.tl = [], this.il = /* @__PURE__ */ new Map(), this.nl = /* @__PURE__ */ new Map();
    }
    sl() {
      return this.Ks() > 0 ? this.tl[this.tl.length - 1] : null;
    }
    el() {
      return this.Ks() > 0 ? this.rl(0) : null;
    }
    An() {
      return this.Ks() > 0 ? this.rl(this.tl.length - 1) : null;
    }
    Ks() {
      return this.tl.length;
    }
    Ni() {
      return 0 === this.Ks();
    }
    Kr(t) {
      return null !== this.hl(t, 0);
    }
    Gh(t) {
      return this.ll(t);
    }
    ll(t, i = 0) {
      const n = this.hl(t, i);
      return null === n ? null : Object.assign(Object.assign({}, this.al(n)), { ee: this.rl(n) });
    }
    ne() {
      return this.tl;
    }
    ol(t, i, n) {
      if (this.Ni())
        return null;
      let s = null;
      for (const e2 of n) {
        s = Fi(s, this._l(t, i, e2));
      }
      return s;
    }
    J(t) {
      this.nl.clear(), this.il.clear(), this.tl = t;
    }
    rl(t) {
      return this.tl[t].ee;
    }
    al(t) {
      return this.tl[t];
    }
    hl(t, i) {
      const n = this.ul(t);
      if (null === n && 0 !== i)
        switch (i) {
          case -1:
            return this.cl(t);
          case 1:
            return this.dl(t);
          default:
            throw new TypeError("Unknown search mode");
        }
      return n;
    }
    cl(t) {
      let i = this.fl(t);
      return i > 0 && (i -= 1), i !== this.tl.length && this.rl(i) < t ? i : null;
    }
    dl(t) {
      const i = this.vl(t);
      return i !== this.tl.length && t < this.rl(i) ? i : null;
    }
    ul(t) {
      const i = this.fl(t);
      return i === this.tl.length || t < this.tl[i].ee ? null : i;
    }
    fl(t) {
      return Bt(this.tl, t, (t2, i) => t2.ee < i);
    }
    vl(t) {
      return At(this.tl, t, (t2, i) => t2.ee > i);
    }
    pl(t, i, n) {
      let s = null;
      for (let e2 = t; e2 < i; e2++) {
        const t2 = this.tl[e2].Vt[n];
        Number.isNaN(t2) || (null === s ? s = { ml: t2, bl: t2 } : (t2 < s.ml && (s.ml = t2), t2 > s.bl && (s.bl = t2)));
      }
      return s;
    }
    _l(t, i, n) {
      if (this.Ni())
        return null;
      let s = null;
      const e2 = b(this.el()), r2 = b(this.An()), h2 = Math.max(t, e2), l2 = Math.min(i, r2), a2 = Math.ceil(h2 / Ei) * Ei, o2 = Math.max(a2, Math.floor(l2 / Ei) * Ei);
      {
        const t2 = this.fl(h2), e3 = this.vl(Math.min(l2, a2, i));
        s = Fi(s, this.pl(t2, e3, n));
      }
      let _2 = this.il.get(n);
      void 0 === _2 && (_2 = /* @__PURE__ */ new Map(), this.il.set(n, _2));
      for (let t2 = Math.max(a2 + 1, h2); t2 < o2; t2 += Ei) {
        const i2 = Math.floor(t2 / Ei);
        let e3 = _2.get(i2);
        if (void 0 === e3) {
          const t3 = this.fl(i2 * Ei), s2 = this.vl((i2 + 1) * Ei - 1);
          e3 = this.pl(t3, s2, n), _2.set(i2, e3);
        }
        s = Fi(s, e3);
      }
      {
        const t2 = this.fl(o2), i2 = this.vl(l2);
        s = Fi(s, this.pl(t2, i2, n));
      }
      return s;
    }
  };
  function Fi(t, i) {
    if (null === t)
      return i;
    if (null === i)
      return t;
    return { ml: Math.min(t.ml, i.ml), bl: Math.max(t.bl, i.bl) };
  }
  var Wi = class {
    constructor(t) {
      this.wl = t;
    }
    X(t, i, n) {
      this.wl.draw(t);
    }
    gl(t, i, n) {
      var s, e2;
      null === (e2 = (s = this.wl).drawBackground) || void 0 === e2 || e2.call(s, t);
    }
  };
  var ji = class {
    constructor(t) {
      this.tr = null, this.wn = t;
    }
    gt() {
      var t;
      const i = this.wn.renderer();
      if (null === i)
        return null;
      if ((null === (t = this.tr) || void 0 === t ? void 0 : t.Ml) === i)
        return this.tr.xl;
      const n = new Wi(i);
      return this.tr = { Ml: i, xl: n }, n;
    }
    Sl() {
      var t, i, n;
      return null !== (n = null === (i = (t = this.wn).zOrder) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : "normal";
    }
  };
  function Hi(t) {
    var i, n, s, e2, r2;
    return { Kt: t.text(), ki: t.coordinate(), Si: null === (i = t.fixedCoordinate) || void 0 === i ? void 0 : i.call(t), V: t.textColor(), t: t.backColor(), yt: null === (s = null === (n = t.visible) || void 0 === n ? void 0 : n.call(t)) || void 0 === s || s, hi: null === (r2 = null === (e2 = t.tickVisible) || void 0 === e2 ? void 0 : e2.call(t)) || void 0 === r2 || r2 };
  }
  var $i = class {
    constructor(t, i) {
      this.Wt = new rt(), this.kl = t, this.yl = i;
    }
    gt() {
      return this.Wt.J(Object.assign({ Hi: this.yl.Hi() }, Hi(this.kl))), this.Wt;
    }
  };
  var Ui = class extends nt {
    constructor(t, i) {
      super(), this.kl = t, this.Li = i;
    }
    zi(t, i, n) {
      const s = Hi(this.kl);
      n.t = s.t, t.V = s.V;
      const e2 = 2 / 12 * this.Li.P();
      n.wi = e2, n.gi = e2, n.ki = s.ki, n.Si = s.Si, t.Kt = s.Kt, t.yt = s.yt, t.hi = s.hi;
    }
  };
  var qi = class {
    constructor(t, i) {
      this.Cl = null, this.Tl = null, this.Pl = null, this.Rl = null, this.Dl = null, this.Vl = t, this.jr = i;
    }
    Ol() {
      return this.Vl;
    }
    Vn() {
      var t, i;
      null === (i = (t = this.Vl).updateAllViews) || void 0 === i || i.call(t);
    }
    Pn() {
      var t, i, n, s;
      const e2 = null !== (n = null === (i = (t = this.Vl).paneViews) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : [];
      if ((null === (s = this.Cl) || void 0 === s ? void 0 : s.Ml) === e2)
        return this.Cl.xl;
      const r2 = e2.map((t2) => new ji(t2));
      return this.Cl = { Ml: e2, xl: r2 }, r2;
    }
    Qi() {
      var t, i, n, s;
      const e2 = null !== (n = null === (i = (t = this.Vl).timeAxisViews) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : [];
      if ((null === (s = this.Tl) || void 0 === s ? void 0 : s.Ml) === e2)
        return this.Tl.xl;
      const r2 = this.jr.$t().St(), h2 = e2.map((t2) => new $i(t2, r2));
      return this.Tl = { Ml: e2, xl: h2 }, h2;
    }
    Rn() {
      var t, i, n, s;
      const e2 = null !== (n = null === (i = (t = this.Vl).priceAxisViews) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : [];
      if ((null === (s = this.Pl) || void 0 === s ? void 0 : s.Ml) === e2)
        return this.Pl.xl;
      const r2 = this.jr.Dt(), h2 = e2.map((t2) => new Ui(t2, r2));
      return this.Pl = { Ml: e2, xl: h2 }, h2;
    }
    Bl() {
      var t, i, n, s;
      const e2 = null !== (n = null === (i = (t = this.Vl).priceAxisPaneViews) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : [];
      if ((null === (s = this.Rl) || void 0 === s ? void 0 : s.Ml) === e2)
        return this.Rl.xl;
      const r2 = e2.map((t2) => new ji(t2));
      return this.Rl = { Ml: e2, xl: r2 }, r2;
    }
    Al() {
      var t, i, n, s;
      const e2 = null !== (n = null === (i = (t = this.Vl).timeAxisPaneViews) || void 0 === i ? void 0 : i.call(t)) && void 0 !== n ? n : [];
      if ((null === (s = this.Dl) || void 0 === s ? void 0 : s.Ml) === e2)
        return this.Dl.xl;
      const r2 = e2.map((t2) => new ji(t2));
      return this.Dl = { Ml: e2, xl: r2 }, r2;
    }
    Il(t, i) {
      var n, s, e2;
      return null !== (e2 = null === (s = (n = this.Vl).autoscaleInfo) || void 0 === s ? void 0 : s.call(n, t, i)) && void 0 !== e2 ? e2 : null;
    }
    wr(t, i) {
      var n, s, e2;
      return null !== (e2 = null === (s = (n = this.Vl).hitTest) || void 0 === s ? void 0 : s.call(n, t, i)) && void 0 !== e2 ? e2 : null;
    }
  };
  function Yi(t, i, n, s) {
    t.forEach((t2) => {
      i(t2).forEach((t3) => {
        t3.Sl() === n && s.push(t3);
      });
    });
  }
  function Zi(t) {
    return t.Pn();
  }
  function Xi(t) {
    return t.Bl();
  }
  function Ki(t) {
    return t.Al();
  }
  var Gi = class extends Ai {
    constructor(t, i, n, s, e2) {
      super(t), this.zt = new Ni(), this.jh = new Ci(this), this.zl = [], this.Ll = new li(this), this.El = null, this.Nl = null, this.Fl = [], this.Wl = [], this.jl = null, this.Hl = [], this.cn = i, this.$l = n;
      const r2 = new Ti(this);
      this.rn = [r2], this.Hh = new ei(r2, this, t), "Area" !== n && "Line" !== n && "Baseline" !== n || (this.El = new ci(this)), this.Ul(), this.ql(e2);
    }
    S() {
      null !== this.jl && clearTimeout(this.jl);
    }
    mh(t) {
      return this.cn.priceLineColor || t;
    }
    Zr(t) {
      const i = { Xr: true }, n = this.Dt();
      if (this.$t().St().Ni() || n.Ni() || this.zt.Ni())
        return i;
      const s = this.$t().St().Xs(), e2 = this.Ct();
      if (null === s || null === e2)
        return i;
      let r2, h2;
      if (t) {
        const t2 = this.zt.sl();
        if (null === t2)
          return i;
        r2 = t2, h2 = t2.ee;
      } else {
        const t2 = this.zt.ll(s.ui(), -1);
        if (null === t2)
          return i;
        if (r2 = this.zt.Gh(t2.ee), null === r2)
          return i;
        h2 = t2.ee;
      }
      const l2 = r2.Vt[3], a2 = this.Us().$s(h2, { Vt: r2 }), o2 = n.Rt(l2, e2.Vt);
      return { Xr: false, _t: l2, Kt: n.Fi(l2, e2.Vt), xh: n.Yl(l2), Sh: n.Zl(l2, e2.Vt), V: a2.ce, ki: o2, ee: h2 };
    }
    Us() {
      return null !== this.Nl || (this.Nl = new zi(this)), this.Nl;
    }
    W() {
      return this.cn;
    }
    $h(t) {
      const i = t.priceScaleId;
      void 0 !== i && i !== this.cn.priceScaleId && this.$t().Xl(this, i), V(this.cn, t), void 0 !== t.priceFormat && (this.Ul(), this.$t().Kl()), this.$t().Gl(this), this.$t().Jl(), this.wn.bt("options");
    }
    J(t, i) {
      this.zt.J(t), this.Ql(), this.wn.bt("data"), this.dn.bt("data"), null !== this.El && (i && i.ta ? this.El.$r() : 0 === t.length && this.El.Hr());
      const n = this.$t().dr(this);
      this.$t().ia(n), this.$t().Gl(this), this.$t().Jl(), this.$t().Uh();
    }
    na(t) {
      this.Fl = t, this.Ql();
      const i = this.$t().dr(this);
      this.dn.bt("data"), this.$t().ia(i), this.$t().Gl(this), this.$t().Jl(), this.$t().Uh();
    }
    sa() {
      return this.Fl;
    }
    dh() {
      return this.Wl;
    }
    ea(t) {
      const i = new Bi(this, t);
      return this.zl.push(i), this.$t().Gl(this), i;
    }
    ra(t) {
      const i = this.zl.indexOf(t);
      -1 !== i && this.zl.splice(i, 1), this.$t().Gl(this);
    }
    Qh() {
      return this.$l;
    }
    Ct() {
      const t = this.ha();
      return null === t ? null : { Vt: t.Vt[3], la: t.ot };
    }
    ha() {
      const t = this.$t().St().Xs();
      if (null === t)
        return null;
      const i = t.Os();
      return this.zt.ll(i, 1);
    }
    In() {
      return this.zt;
    }
    ph(t) {
      const i = this.zt.Gh(t);
      return null === i ? null : "Bar" === this.$l || "Candlestick" === this.$l || "Custom" === this.$l ? { ge: i.Vt[0], Me: i.Vt[1], xe: i.Vt[2], Se: i.Vt[3] } : i.Vt[3];
    }
    aa(t) {
      const i = [];
      Yi(this.Hl, Zi, "top", i);
      const n = this.El;
      return null !== n && n.yt() ? (null === this.jl && n.qr() && (this.jl = setTimeout(() => {
        this.jl = null, this.$t().oa();
      }, 0)), n.Ur(), i.unshift(n), i) : i;
    }
    Pn() {
      const t = [];
      this._a() || t.push(this.Ll), t.push(this.wn, this.jh, this.dn);
      const i = this.zl.map((t2) => t2.qh());
      return t.push(...i), Yi(this.Hl, Zi, "normal", t), t;
    }
    ua() {
      return this.ca(Zi, "bottom");
    }
    da(t) {
      return this.ca(Xi, t);
    }
    fa(t) {
      return this.ca(Ki, t);
    }
    va(t, i) {
      return this.Hl.map((n) => n.wr(t, i)).filter((t2) => null !== t2);
    }
    Ji(t) {
      return [this.Hh, ...this.zl.map((t2) => t2.Yh())];
    }
    Rn(t, i) {
      if (i !== this.Yi && !this._a())
        return [];
      const n = [...this.rn];
      for (const t2 of this.zl)
        n.push(t2.Zh());
      return this.Hl.forEach((t2) => {
        n.push(...t2.Rn());
      }), n;
    }
    Qi() {
      const t = [];
      return this.Hl.forEach((i) => {
        t.push(...i.Qi());
      }), t;
    }
    Il(t, i) {
      if (void 0 !== this.cn.autoscaleInfoProvider) {
        const n = this.cn.autoscaleInfoProvider(() => {
          const n2 = this.pa(t, i);
          return null === n2 ? null : n2.Bh();
        });
        return Di.Ah(n);
      }
      return this.pa(t, i);
    }
    ma() {
      return this.cn.priceFormat.minMove;
    }
    ba() {
      return this.wa;
    }
    Vn() {
      var t;
      this.wn.bt(), this.dn.bt();
      for (const t2 of this.rn)
        t2.bt();
      for (const t2 of this.zl)
        t2.bt();
      this.jh.bt(), this.Ll.bt(), null === (t = this.El) || void 0 === t || t.bt(), this.Hl.forEach((t2) => t2.Vn());
    }
    Dt() {
      return b(super.Dt());
    }
    kt(t) {
      if (!(("Line" === this.$l || "Area" === this.$l || "Baseline" === this.$l) && this.cn.crosshairMarkerVisible))
        return null;
      const i = this.zt.Gh(t);
      if (null === i)
        return null;
      return { _t: i.Vt[3], ht: this.ga(), Ot: this.Ma(), Pt: this.xa(), Tt: this.Sa(t) };
    }
    bh() {
      return this.cn.title;
    }
    yt() {
      return this.cn.visible;
    }
    ka(t) {
      this.Hl.push(new qi(t, this));
    }
    ya(t) {
      this.Hl = this.Hl.filter((i) => i.Ol() !== t);
    }
    Ca() {
      if (this.wn instanceof Kt != false)
        return (t) => this.wn.We(t);
    }
    Ta() {
      if (this.wn instanceof Kt != false)
        return (t) => this.wn.je(t);
    }
    _a() {
      return !_t(this.Dt().Pa());
    }
    pa(t, i) {
      if (!B(t) || !B(i) || this.zt.Ni())
        return null;
      const n = "Line" === this.$l || "Area" === this.$l || "Baseline" === this.$l || "Histogram" === this.$l ? [3] : [2, 1], s = this.zt.ol(t, i, n);
      let e2 = null !== s ? new Ri(s.ml, s.bl) : null;
      if ("Histogram" === this.Qh()) {
        const t2 = this.cn.base, i2 = new Ri(t2, t2);
        e2 = null !== e2 ? e2.ts(i2) : i2;
      }
      let r2 = this.dn.uh();
      return this.Hl.forEach((n2) => {
        const s2 = n2.Il(t, i);
        if (null == s2 ? void 0 : s2.priceRange) {
          const t2 = new Ri(s2.priceRange.minValue, s2.priceRange.maxValue);
          e2 = null !== e2 ? e2.ts(t2) : t2;
        }
        var h2, l2, a2, o2;
        (null == s2 ? void 0 : s2.margins) && (h2 = r2, l2 = s2.margins, r2 = { above: Math.max(null !== (a2 = null == h2 ? void 0 : h2.above) && void 0 !== a2 ? a2 : 0, l2.above), below: Math.max(null !== (o2 = null == h2 ? void 0 : h2.below) && void 0 !== o2 ? o2 : 0, l2.below) });
      }), new Di(e2, r2);
    }
    ga() {
      switch (this.$l) {
        case "Line":
        case "Area":
        case "Baseline":
          return this.cn.crosshairMarkerRadius;
      }
      return 0;
    }
    Ma() {
      switch (this.$l) {
        case "Line":
        case "Area":
        case "Baseline": {
          const t = this.cn.crosshairMarkerBorderColor;
          if (0 !== t.length)
            return t;
        }
      }
      return null;
    }
    xa() {
      switch (this.$l) {
        case "Line":
        case "Area":
        case "Baseline":
          return this.cn.crosshairMarkerBorderWidth;
      }
      return 0;
    }
    Sa(t) {
      switch (this.$l) {
        case "Line":
        case "Area":
        case "Baseline": {
          const t2 = this.cn.crosshairMarkerBackgroundColor;
          if (0 !== t2.length)
            return t2;
        }
      }
      return this.Us().$s(t).ce;
    }
    Ul() {
      switch (this.cn.priceFormat.type) {
        case "custom":
          this.wa = { format: this.cn.priceFormat.formatter };
          break;
        case "volume":
          this.wa = new pt(this.cn.priceFormat.precision);
          break;
        case "percent":
          this.wa = new vt(this.cn.priceFormat.precision);
          break;
        default: {
          const t = Math.pow(10, this.cn.priceFormat.precision);
          this.wa = new ft(t, this.cn.priceFormat.minMove * t);
        }
      }
      null !== this.Yi && this.Yi.Ra();
    }
    Ql() {
      const t = this.$t().St();
      if (!t.Da() || this.zt.Ni())
        return void (this.Wl = []);
      const i = b(this.zt.el());
      this.Wl = this.Fl.map((n, s) => {
        const e2 = b(t.Va(n.time, true)), r2 = e2 < i ? 1 : -1;
        return { time: b(this.zt.ll(e2, r2)).ee, position: n.position, shape: n.shape, color: n.color, id: n.id, th: s, text: n.text, size: n.size, originalTime: n.originalTime };
      });
    }
    ql(t) {
      switch (this.dn = new yi(this, this.$t()), this.$l) {
        case "Bar":
          this.wn = new Ht(this, this.$t());
          break;
        case "Candlestick":
          this.wn = new Zt(this, this.$t());
          break;
        case "Line":
          this.wn = new ti(this, this.$t());
          break;
        case "Custom":
          this.wn = new Kt(this, this.$t(), m(t));
          break;
        case "Area":
          this.wn = new Ft(this, this.$t());
          break;
        case "Baseline":
          this.wn = new qt(this, this.$t());
          break;
        case "Histogram":
          this.wn = new Qt(this, this.$t());
          break;
        default:
          throw Error("Unknown chart style assigned: " + this.$l);
      }
    }
    ca(t, i) {
      const n = [];
      return Yi(this.Hl, t, i, n), n;
    }
  };
  var Ji = class {
    constructor(t) {
      this.cn = t;
    }
    Oa(t, i, n) {
      let s = t;
      if (0 === this.cn.mode)
        return s;
      const e2 = n.vn(), r2 = e2.Ct();
      if (null === r2)
        return s;
      const h2 = e2.Rt(t, r2), l2 = n.Ba().filter((t2) => t2 instanceof Gi).reduce((t2, s2) => {
        if (n.vr(s2) || !s2.yt())
          return t2;
        const e3 = s2.Dt(), r3 = s2.In();
        if (e3.Ni() || !r3.Kr(i))
          return t2;
        const h3 = r3.Gh(i);
        if (null === h3)
          return t2;
        const l3 = w(s2.Ct());
        return t2.concat([e3.Rt(h3.Vt[3], l3.Vt)]);
      }, []);
      if (0 === l2.length)
        return s;
      l2.sort((t2, i2) => Math.abs(t2 - h2) - Math.abs(i2 - h2));
      const a2 = l2[0];
      return s = e2.pn(a2, r2), s;
    }
  };
  var Qi = class extends H {
    constructor() {
      super(...arguments), this.zt = null;
    }
    J(t) {
      this.zt = t;
    }
    K({ context: t, bitmapSize: i, horizontalPixelRatio: n, verticalPixelRatio: s }) {
      if (null === this.zt)
        return;
      const e2 = Math.max(1, Math.floor(n));
      t.lineWidth = e2, function(t2, i2) {
        t2.save(), t2.lineWidth % 2 && t2.translate(0.5, 0.5), i2(), t2.restore();
      }(t, () => {
        const r2 = b(this.zt);
        if (r2.Aa) {
          t.strokeStyle = r2.Ia, f(t, r2.za), t.beginPath();
          for (const s2 of r2.La) {
            const r3 = Math.round(s2.Ea * n);
            t.moveTo(r3, -e2), t.lineTo(r3, i.height + e2);
          }
          t.stroke();
        }
        if (r2.Na) {
          t.strokeStyle = r2.Fa, f(t, r2.Wa), t.beginPath();
          for (const n2 of r2.ja) {
            const r3 = Math.round(n2.Ea * s);
            t.moveTo(-e2, r3), t.lineTo(i.width + e2, r3);
          }
          t.stroke();
        }
      });
    }
  };
  var tn = class {
    constructor(t) {
      this.Wt = new Qi(), this.ft = true, this.tn = t;
    }
    bt() {
      this.ft = true;
    }
    gt() {
      if (this.ft) {
        const t = this.tn.$t().W().grid, i = { Na: t.horzLines.visible, Aa: t.vertLines.visible, Fa: t.horzLines.color, Ia: t.vertLines.color, Wa: t.horzLines.style, za: t.vertLines.style, ja: this.tn.vn().Ha(), La: (this.tn.$t().St().Ha() || []).map((t2) => ({ Ea: t2.coord })) };
        this.Wt.J(i), this.ft = false;
      }
      return this.Wt;
    }
  };
  var nn = class {
    constructor(t) {
      this.wn = new tn(t);
    }
    qh() {
      return this.wn;
    }
  };
  var sn = { $a: 4, Ua: 1e-4 };
  function en(t, i) {
    const n = 100 * (t - i) / i;
    return i < 0 ? -n : n;
  }
  function rn(t, i) {
    const n = en(t.Ph(), i), s = en(t.Rh(), i);
    return new Ri(n, s);
  }
  function hn(t, i) {
    const n = 100 * (t - i) / i + 100;
    return i < 0 ? -n : n;
  }
  function ln(t, i) {
    const n = hn(t.Ph(), i), s = hn(t.Rh(), i);
    return new Ri(n, s);
  }
  function an(t, i) {
    const n = Math.abs(t);
    if (n < 1e-15)
      return 0;
    const s = Math.log10(n + i.Ua) + i.$a;
    return t < 0 ? -s : s;
  }
  function on(t, i) {
    const n = Math.abs(t);
    if (n < 1e-15)
      return 0;
    const s = Math.pow(10, n - i.$a) - i.Ua;
    return t < 0 ? -s : s;
  }
  function _n(t, i) {
    if (null === t)
      return null;
    const n = an(t.Ph(), i), s = an(t.Rh(), i);
    return new Ri(n, s);
  }
  function un(t, i) {
    if (null === t)
      return null;
    const n = on(t.Ph(), i), s = on(t.Rh(), i);
    return new Ri(n, s);
  }
  function cn(t) {
    if (null === t)
      return sn;
    const i = Math.abs(t.Rh() - t.Ph());
    if (i >= 1 || i < 1e-15)
      return sn;
    const n = Math.ceil(Math.abs(Math.log10(i))), s = sn.$a + n;
    return { $a: s, Ua: 1 / Math.pow(10, s) };
  }
  var dn = class {
    constructor(t, i) {
      if (this.qa = t, this.Ya = i, function(t2) {
        if (t2 < 0)
          return false;
        for (let i2 = t2; i2 > 1; i2 /= 10)
          if (i2 % 10 != 0)
            return false;
        return true;
      }(this.qa))
        this.Za = [2, 2.5, 2];
      else {
        this.Za = [];
        for (let t2 = this.qa; 1 !== t2; ) {
          if (t2 % 2 == 0)
            this.Za.push(2), t2 /= 2;
          else {
            if (t2 % 5 != 0)
              throw new Error("unexpected base");
            this.Za.push(2, 2.5), t2 /= 5;
          }
          if (this.Za.length > 100)
            throw new Error("something wrong with base");
        }
      }
    }
    Xa(t, i, n) {
      const s = 0 === this.qa ? 0 : 1 / this.qa;
      let e2 = Math.pow(10, Math.max(0, Math.ceil(Math.log10(t - i)))), r2 = 0, h2 = this.Ya[0];
      for (; ; ) {
        const t2 = yt(e2, s, 1e-14) && e2 > s + 1e-14, i2 = yt(e2, n * h2, 1e-14), l3 = yt(e2, 1, 1e-14);
        if (!(t2 && i2 && l3))
          break;
        e2 /= h2, h2 = this.Ya[++r2 % this.Ya.length];
      }
      if (e2 <= s + 1e-14 && (e2 = s), e2 = Math.max(1, e2), this.Za.length > 0 && (l2 = e2, a2 = 1, o2 = 1e-14, Math.abs(l2 - a2) < o2))
        for (r2 = 0, h2 = this.Za[0]; yt(e2, n * h2, 1e-14) && e2 > s + 1e-14; )
          e2 /= h2, h2 = this.Za[++r2 % this.Za.length];
      var l2, a2, o2;
      return e2;
    }
  };
  var fn = class {
    constructor(t, i, n, s) {
      this.Ka = [], this.Li = t, this.qa = i, this.Ga = n, this.Ja = s;
    }
    Xa(t, i) {
      if (t < i)
        throw new Error("high < low");
      const n = this.Li.At(), s = (t - i) * this.Qa() / n, e2 = new dn(this.qa, [2, 2.5, 2]), r2 = new dn(this.qa, [2, 2, 2.5]), h2 = new dn(this.qa, [2.5, 2, 2]), l2 = [];
      return l2.push(e2.Xa(t, i, s), r2.Xa(t, i, s), h2.Xa(t, i, s)), function(t2) {
        if (t2.length < 1)
          throw Error("array is empty");
        let i2 = t2[0];
        for (let n2 = 1; n2 < t2.length; ++n2)
          t2[n2] < i2 && (i2 = t2[n2]);
        return i2;
      }(l2);
    }
    io() {
      const t = this.Li, i = t.Ct();
      if (null === i)
        return void (this.Ka = []);
      const n = t.At(), s = this.Ga(n - 1, i), e2 = this.Ga(0, i), r2 = this.Li.W().entireTextOnly ? this.no() / 2 : 0, h2 = r2, l2 = n - 1 - r2, a2 = Math.max(s, e2), o2 = Math.min(s, e2);
      if (a2 === o2)
        return void (this.Ka = []);
      let _2 = this.Xa(a2, o2), u2 = a2 % _2;
      u2 += u2 < 0 ? _2 : 0;
      const c2 = a2 >= o2 ? 1 : -1;
      let d2 = null, f2 = 0;
      for (let n2 = a2 - u2; n2 > o2; n2 -= _2) {
        const s2 = this.Ja(n2, i, true);
        null !== d2 && Math.abs(s2 - d2) < this.Qa() || (s2 < h2 || s2 > l2 || (f2 < this.Ka.length ? (this.Ka[f2].Ea = s2, this.Ka[f2].so = t.eo(n2)) : this.Ka.push({ Ea: s2, so: t.eo(n2) }), f2++, d2 = s2, t.ro() && (_2 = this.Xa(n2 * c2, o2))));
      }
      this.Ka.length = f2;
    }
    Ha() {
      return this.Ka;
    }
    no() {
      return this.Li.P();
    }
    Qa() {
      return Math.ceil(2.5 * this.no());
    }
  };
  function vn(t) {
    return t.slice().sort((t2, i) => b(t2.Xi()) - b(i.Xi()));
  }
  var pn;
  !function(t) {
    t[t.Normal = 0] = "Normal", t[t.Logarithmic = 1] = "Logarithmic", t[t.Percentage = 2] = "Percentage", t[t.IndexedTo100 = 3] = "IndexedTo100";
  }(pn || (pn = {}));
  var mn = new vt();
  var bn = new ft(100, 1);
  var wn = class {
    constructor(t, i, n, s) {
      this.ho = 0, this.lo = null, this.Ih = null, this.ao = null, this.oo = { _o: false, uo: null }, this.co = 0, this.do = 0, this.fo = new D(), this.vo = new D(), this.po = [], this.mo = null, this.bo = null, this.wo = null, this.Mo = null, this.wa = bn, this.xo = cn(null), this.So = t, this.cn = i, this.ko = n, this.yo = s, this.Co = new fn(this, 100, this.To.bind(this), this.Po.bind(this));
    }
    Pa() {
      return this.So;
    }
    W() {
      return this.cn;
    }
    $h(t) {
      if (V(this.cn, t), this.Ra(), void 0 !== t.mode && this.Ro({ Cr: t.mode }), void 0 !== t.scaleMargins) {
        const i = m(t.scaleMargins.top), n = m(t.scaleMargins.bottom);
        if (i < 0 || i > 1)
          throw new Error(`Invalid top margin - expect value between 0 and 1, given=${i}`);
        if (n < 0 || n > 1)
          throw new Error(`Invalid bottom margin - expect value between 0 and 1, given=${n}`);
        if (i + n > 1)
          throw new Error(`Invalid margins - sum of margins must be less than 1, given=${i + n}`);
        this.Do(), this.bo = null;
      }
    }
    Vo() {
      return this.cn.autoScale;
    }
    ro() {
      return 1 === this.cn.mode;
    }
    Mh() {
      return 2 === this.cn.mode;
    }
    Oo() {
      return 3 === this.cn.mode;
    }
    Cr() {
      return { Wn: this.cn.autoScale, Bo: this.cn.invertScale, Cr: this.cn.mode };
    }
    Ro(t) {
      const i = this.Cr();
      let n = null;
      void 0 !== t.Wn && (this.cn.autoScale = t.Wn), void 0 !== t.Cr && (this.cn.mode = t.Cr, 2 !== t.Cr && 3 !== t.Cr || (this.cn.autoScale = true), this.oo._o = false), 1 === i.Cr && t.Cr !== i.Cr && (!function(t2, i2) {
        if (null === t2)
          return false;
        const n2 = on(t2.Ph(), i2), s2 = on(t2.Rh(), i2);
        return isFinite(n2) && isFinite(s2);
      }(this.Ih, this.xo) ? this.cn.autoScale = true : (n = un(this.Ih, this.xo), null !== n && this.Ao(n))), 1 === t.Cr && t.Cr !== i.Cr && (n = _n(this.Ih, this.xo), null !== n && this.Ao(n));
      const s = i.Cr !== this.cn.mode;
      s && (2 === i.Cr || this.Mh()) && this.Ra(), s && (3 === i.Cr || this.Oo()) && this.Ra(), void 0 !== t.Bo && i.Bo !== t.Bo && (this.cn.invertScale = t.Bo, this.Io()), this.vo.m(i, this.Cr());
    }
    zo() {
      return this.vo;
    }
    P() {
      return this.ko.fontSize;
    }
    At() {
      return this.ho;
    }
    Lo(t) {
      this.ho !== t && (this.ho = t, this.Do(), this.bo = null);
    }
    Eo() {
      if (this.lo)
        return this.lo;
      const t = this.At() - this.No() - this.Fo();
      return this.lo = t, t;
    }
    Lh() {
      return this.Wo(), this.Ih;
    }
    Ao(t, i) {
      const n = this.Ih;
      (i || null === n && null !== t || null !== n && !n.Ch(t)) && (this.bo = null, this.Ih = t);
    }
    Ni() {
      return this.Wo(), 0 === this.ho || !this.Ih || this.Ih.Ni();
    }
    jo(t) {
      return this.Bo() ? t : this.At() - 1 - t;
    }
    Rt(t, i) {
      return this.Mh() ? t = en(t, i) : this.Oo() && (t = hn(t, i)), this.Po(t, i);
    }
    te(t, i, n) {
      this.Wo();
      const s = this.Fo(), e2 = b(this.Lh()), r2 = e2.Ph(), h2 = e2.Rh(), l2 = this.Eo() - 1, a2 = this.Bo(), o2 = l2 / (h2 - r2), _2 = void 0 === n ? 0 : n.from, u2 = void 0 === n ? t.length : n.to, c2 = this.Ho();
      for (let n2 = _2; n2 < u2; n2++) {
        const e3 = t[n2], h3 = e3._t;
        if (isNaN(h3))
          continue;
        let l3 = h3;
        null !== c2 && (l3 = c2(e3._t, i));
        const _3 = s + o2 * (l3 - r2), u3 = a2 ? _3 : this.ho - 1 - _3;
        e3.st = u3;
      }
    }
    be(t, i, n) {
      this.Wo();
      const s = this.Fo(), e2 = b(this.Lh()), r2 = e2.Ph(), h2 = e2.Rh(), l2 = this.Eo() - 1, a2 = this.Bo(), o2 = l2 / (h2 - r2), _2 = void 0 === n ? 0 : n.from, u2 = void 0 === n ? t.length : n.to, c2 = this.Ho();
      for (let n2 = _2; n2 < u2; n2++) {
        const e3 = t[n2];
        let h3 = e3.ge, l3 = e3.Me, _3 = e3.xe, u3 = e3.Se;
        null !== c2 && (h3 = c2(e3.ge, i), l3 = c2(e3.Me, i), _3 = c2(e3.xe, i), u3 = c2(e3.Se, i));
        let d2 = s + o2 * (h3 - r2), f2 = a2 ? d2 : this.ho - 1 - d2;
        e3.pe = f2, d2 = s + o2 * (l3 - r2), f2 = a2 ? d2 : this.ho - 1 - d2, e3.de = f2, d2 = s + o2 * (_3 - r2), f2 = a2 ? d2 : this.ho - 1 - d2, e3.fe = f2, d2 = s + o2 * (u3 - r2), f2 = a2 ? d2 : this.ho - 1 - d2, e3.me = f2;
      }
    }
    pn(t, i) {
      const n = this.To(t, i);
      return this.$o(n, i);
    }
    $o(t, i) {
      let n = t;
      return this.Mh() ? n = function(t2, i2) {
        return i2 < 0 && (t2 = -t2), t2 / 100 * i2 + i2;
      }(n, i) : this.Oo() && (n = function(t2, i2) {
        return t2 -= 100, i2 < 0 && (t2 = -t2), t2 / 100 * i2 + i2;
      }(n, i)), n;
    }
    Ba() {
      return this.po;
    }
    Uo() {
      if (this.mo)
        return this.mo;
      let t = [];
      for (let i = 0; i < this.po.length; i++) {
        const n = this.po[i];
        null === n.Xi() && n.Ki(i + 1), t.push(n);
      }
      return t = vn(t), this.mo = t, this.mo;
    }
    qo(t) {
      -1 === this.po.indexOf(t) && (this.po.push(t), this.Ra(), this.Yo());
    }
    Zo(t) {
      const i = this.po.indexOf(t);
      if (-1 === i)
        throw new Error("source is not attached to scale");
      this.po.splice(i, 1), 0 === this.po.length && (this.Ro({ Wn: true }), this.Ao(null)), this.Ra(), this.Yo();
    }
    Ct() {
      let t = null;
      for (const i of this.po) {
        const n = i.Ct();
        null !== n && ((null === t || n.la < t.la) && (t = n));
      }
      return null === t ? null : t.Vt;
    }
    Bo() {
      return this.cn.invertScale;
    }
    Ha() {
      const t = null === this.Ct();
      if (null !== this.bo && (t || this.bo.Xo === t))
        return this.bo.Ha;
      this.Co.io();
      const i = this.Co.Ha();
      return this.bo = { Ha: i, Xo: t }, this.fo.m(), i;
    }
    Ko() {
      return this.fo;
    }
    Go(t) {
      this.Mh() || this.Oo() || null === this.wo && null === this.ao && (this.Ni() || (this.wo = this.ho - t, this.ao = b(this.Lh()).Th()));
    }
    Jo(t) {
      if (this.Mh() || this.Oo())
        return;
      if (null === this.wo)
        return;
      this.Ro({ Wn: false }), (t = this.ho - t) < 0 && (t = 0);
      let i = (this.wo + 0.2 * (this.ho - 1)) / (t + 0.2 * (this.ho - 1));
      const n = b(this.ao).Th();
      i = Math.max(i, 0.1), n.Vh(i), this.Ao(n);
    }
    Qo() {
      this.Mh() || this.Oo() || (this.wo = null, this.ao = null);
    }
    t_(t) {
      this.Vo() || null === this.Mo && null === this.ao && (this.Ni() || (this.Mo = t, this.ao = b(this.Lh()).Th()));
    }
    i_(t) {
      if (this.Vo())
        return;
      if (null === this.Mo)
        return;
      const i = b(this.Lh()).Dh() / (this.Eo() - 1);
      let n = t - this.Mo;
      this.Bo() && (n *= -1);
      const s = n * i, e2 = b(this.ao).Th();
      e2.Oh(s), this.Ao(e2, true), this.bo = null;
    }
    n_() {
      this.Vo() || null !== this.Mo && (this.Mo = null, this.ao = null);
    }
    ba() {
      return this.wa || this.Ra(), this.wa;
    }
    Fi(t, i) {
      switch (this.cn.mode) {
        case 2:
          return this.s_(en(t, i));
        case 3:
          return this.ba().format(hn(t, i));
        default:
          return this.Wh(t);
      }
    }
    eo(t) {
      switch (this.cn.mode) {
        case 2:
          return this.s_(t);
        case 3:
          return this.ba().format(t);
        default:
          return this.Wh(t);
      }
    }
    Yl(t) {
      return this.Wh(t, b(this.e_()).ba());
    }
    Zl(t, i) {
      return t = en(t, i), this.s_(t, mn);
    }
    r_() {
      return this.po;
    }
    h_(t) {
      this.oo = { uo: t, _o: false };
    }
    Vn() {
      this.po.forEach((t) => t.Vn());
    }
    Ra() {
      this.bo = null;
      const t = this.e_();
      let i = 100;
      null !== t && (i = Math.round(1 / t.ma())), this.wa = bn, this.Mh() ? (this.wa = mn, i = 100) : this.Oo() ? (this.wa = new ft(100, 1), i = 100) : null !== t && (this.wa = t.ba()), this.Co = new fn(this, i, this.To.bind(this), this.Po.bind(this)), this.Co.io();
    }
    Yo() {
      this.mo = null;
    }
    e_() {
      return this.po[0] || null;
    }
    No() {
      return this.Bo() ? this.cn.scaleMargins.bottom * this.At() + this.do : this.cn.scaleMargins.top * this.At() + this.co;
    }
    Fo() {
      return this.Bo() ? this.cn.scaleMargins.top * this.At() + this.co : this.cn.scaleMargins.bottom * this.At() + this.do;
    }
    Wo() {
      this.oo._o || (this.oo._o = true, this.l_());
    }
    Do() {
      this.lo = null;
    }
    Po(t, i) {
      if (this.Wo(), this.Ni())
        return 0;
      t = this.ro() && t ? an(t, this.xo) : t;
      const n = b(this.Lh()), s = this.Fo() + (this.Eo() - 1) * (t - n.Ph()) / n.Dh();
      return this.jo(s);
    }
    To(t, i) {
      if (this.Wo(), this.Ni())
        return 0;
      const n = this.jo(t), s = b(this.Lh()), e2 = s.Ph() + s.Dh() * ((n - this.Fo()) / (this.Eo() - 1));
      return this.ro() ? on(e2, this.xo) : e2;
    }
    Io() {
      this.bo = null, this.Co.io();
    }
    l_() {
      const t = this.oo.uo;
      if (null === t)
        return;
      let i = null;
      const n = this.r_();
      let s = 0, e2 = 0;
      for (const r3 of n) {
        if (!r3.yt())
          continue;
        const n2 = r3.Ct();
        if (null === n2)
          continue;
        const h3 = r3.Il(t.Os(), t.ui());
        let l2 = h3 && h3.Lh();
        if (null !== l2) {
          switch (this.cn.mode) {
            case 1:
              l2 = _n(l2, this.xo);
              break;
            case 2:
              l2 = rn(l2, n2.Vt);
              break;
            case 3:
              l2 = ln(l2, n2.Vt);
          }
          if (i = null === i ? l2 : i.ts(b(l2)), null !== h3) {
            const t2 = h3.Eh();
            null !== t2 && (s = Math.max(s, t2.above), e2 = Math.max(e2, t2.below));
          }
        }
      }
      if (s === this.co && e2 === this.do || (this.co = s, this.do = e2, this.bo = null, this.Do()), null !== i) {
        if (i.Ph() === i.Rh()) {
          const t2 = this.e_(), n2 = 5 * (null === t2 || this.Mh() || this.Oo() ? 1 : t2.ma());
          this.ro() && (i = un(i, this.xo)), i = new Ri(i.Ph() - n2, i.Rh() + n2), this.ro() && (i = _n(i, this.xo));
        }
        if (this.ro()) {
          const t2 = un(i, this.xo), n2 = cn(t2);
          if (r2 = n2, h2 = this.xo, r2.$a !== h2.$a || r2.Ua !== h2.Ua) {
            const s2 = null !== this.ao ? un(this.ao, this.xo) : null;
            this.xo = n2, i = _n(t2, n2), null !== s2 && (this.ao = _n(s2, n2));
          }
        }
        this.Ao(i);
      } else
        null === this.Ih && (this.Ao(new Ri(-0.5, 0.5)), this.xo = cn(null));
      var r2, h2;
      this.oo._o = true;
    }
    Ho() {
      return this.Mh() ? en : this.Oo() ? hn : this.ro() ? (t) => an(t, this.xo) : null;
    }
    a_(t, i, n) {
      return void 0 === i ? (void 0 === n && (n = this.ba()), n.format(t)) : i(t);
    }
    Wh(t, i) {
      return this.a_(t, this.yo.priceFormatter, i);
    }
    s_(t, i) {
      return this.a_(t, this.yo.percentageFormatter, i);
    }
  };
  var gn = class {
    constructor(t, i) {
      this.po = [], this.o_ = /* @__PURE__ */ new Map(), this.ho = 0, this.__ = 0, this.u_ = 1e3, this.mo = null, this.c_ = new D(), this.yl = t, this.$i = i, this.d_ = new nn(this);
      const n = i.W();
      this.f_ = this.v_("left", n.leftPriceScale), this.p_ = this.v_("right", n.rightPriceScale), this.f_.zo().l(this.m_.bind(this, this.f_), this), this.p_.zo().l(this.m_.bind(this, this.p_), this), this.b_(n);
    }
    b_(t) {
      if (t.leftPriceScale && this.f_.$h(t.leftPriceScale), t.rightPriceScale && this.p_.$h(t.rightPriceScale), t.localization && (this.f_.Ra(), this.p_.Ra()), t.overlayPriceScales) {
        const i = Array.from(this.o_.values());
        for (const n of i) {
          const i2 = b(n[0].Dt());
          i2.$h(t.overlayPriceScales), t.localization && i2.Ra();
        }
      }
    }
    w_(t) {
      switch (t) {
        case "left":
          return this.f_;
        case "right":
          return this.p_;
      }
      return this.o_.has(t) ? m(this.o_.get(t))[0].Dt() : null;
    }
    S() {
      this.$t().g_().p(this), this.f_.zo().p(this), this.p_.zo().p(this), this.po.forEach((t) => {
        t.S && t.S();
      }), this.c_.m();
    }
    M_() {
      return this.u_;
    }
    x_(t) {
      this.u_ = t;
    }
    $t() {
      return this.$i;
    }
    Hi() {
      return this.__;
    }
    At() {
      return this.ho;
    }
    S_(t) {
      this.__ = t, this.k_();
    }
    Lo(t) {
      this.ho = t, this.f_.Lo(t), this.p_.Lo(t), this.po.forEach((i) => {
        if (this.vr(i)) {
          const n = i.Dt();
          null !== n && n.Lo(t);
        }
      }), this.k_();
    }
    Ba() {
      return this.po;
    }
    vr(t) {
      const i = t.Dt();
      return null === i || this.f_ !== i && this.p_ !== i;
    }
    qo(t, i, n) {
      const s = void 0 !== n ? n : this.C_().y_ + 1;
      this.T_(t, i, s);
    }
    Zo(t) {
      const i = this.po.indexOf(t);
      p(-1 !== i, "removeDataSource: invalid data source"), this.po.splice(i, 1);
      const n = b(t.Dt()).Pa();
      if (this.o_.has(n)) {
        const i2 = m(this.o_.get(n)), s2 = i2.indexOf(t);
        -1 !== s2 && (i2.splice(s2, 1), 0 === i2.length && this.o_.delete(n));
      }
      const s = t.Dt();
      s && s.Ba().indexOf(t) >= 0 && s.Zo(t), null !== s && (s.Yo(), this.P_(s)), this.mo = null;
    }
    mr(t) {
      return t === this.f_ ? "left" : t === this.p_ ? "right" : "overlay";
    }
    R_() {
      return this.f_;
    }
    D_() {
      return this.p_;
    }
    V_(t, i) {
      t.Go(i);
    }
    O_(t, i) {
      t.Jo(i), this.k_();
    }
    B_(t) {
      t.Qo();
    }
    A_(t, i) {
      t.t_(i);
    }
    I_(t, i) {
      t.i_(i), this.k_();
    }
    z_(t) {
      t.n_();
    }
    k_() {
      this.po.forEach((t) => {
        t.Vn();
      });
    }
    vn() {
      let t = null;
      return this.$i.W().rightPriceScale.visible && 0 !== this.p_.Ba().length ? t = this.p_ : this.$i.W().leftPriceScale.visible && 0 !== this.f_.Ba().length ? t = this.f_ : 0 !== this.po.length && (t = this.po[0].Dt()), null === t && (t = this.p_), t;
    }
    pr() {
      let t = null;
      return this.$i.W().rightPriceScale.visible ? t = this.p_ : this.$i.W().leftPriceScale.visible && (t = this.f_), t;
    }
    P_(t) {
      null !== t && t.Vo() && this.L_(t);
    }
    E_(t) {
      const i = this.yl.Xs();
      t.Ro({ Wn: true }), null !== i && t.h_(i), this.k_();
    }
    N_() {
      this.L_(this.f_), this.L_(this.p_);
    }
    F_() {
      this.P_(this.f_), this.P_(this.p_), this.po.forEach((t) => {
        this.vr(t) && this.P_(t.Dt());
      }), this.k_(), this.$i.Uh();
    }
    Uo() {
      return null === this.mo && (this.mo = vn(this.po)), this.mo;
    }
    W_() {
      return this.c_;
    }
    j_() {
      return this.d_;
    }
    L_(t) {
      const i = t.r_();
      if (i && i.length > 0 && !this.yl.Ni()) {
        const i2 = this.yl.Xs();
        null !== i2 && t.h_(i2);
      }
      t.Vn();
    }
    C_() {
      const t = this.Uo();
      if (0 === t.length)
        return { H_: 0, y_: 0 };
      let i = 0, n = 0;
      for (let s = 0; s < t.length; s++) {
        const e2 = t[s].Xi();
        null !== e2 && (e2 < i && (i = e2), e2 > n && (n = e2));
      }
      return { H_: i, y_: n };
    }
    T_(t, i, n) {
      let s = this.w_(i);
      if (null === s && (s = this.v_(i, this.$i.W().overlayPriceScales)), this.po.push(t), !_t(i)) {
        const n2 = this.o_.get(i) || [];
        n2.push(t), this.o_.set(i, n2);
      }
      s.qo(t), t.Gi(s), t.Ki(n), this.P_(s), this.mo = null;
    }
    m_(t, i, n) {
      i.Cr !== n.Cr && this.L_(t);
    }
    v_(t, i) {
      const n = Object.assign({ visible: true, autoScale: true }, z(i)), s = new wn(t, n, this.$i.W().layout, this.$i.W().localization);
      return s.Lo(this.At()), s;
    }
  };
  var Mn = class {
    constructor(t, i, n = 50) {
      this.Ke = 0, this.Ge = 1, this.Je = 1, this.tr = /* @__PURE__ */ new Map(), this.Qe = /* @__PURE__ */ new Map(), this.U_ = t, this.q_ = i, this.ir = n;
    }
    Y_(t) {
      const i = t.time, n = this.q_.cacheKey(i), s = this.tr.get(n);
      if (void 0 !== s)
        return s.Z_;
      if (this.Ke === this.ir) {
        const t2 = this.Qe.get(this.Je);
        this.Qe.delete(this.Je), this.tr.delete(m(t2)), this.Je++, this.Ke--;
      }
      const e2 = this.U_(t);
      return this.tr.set(n, { Z_: e2, rr: this.Ge }), this.Qe.set(this.Ge, n), this.Ke++, this.Ge++, e2;
    }
  };
  var xn = class {
    constructor(t, i) {
      p(t <= i, "right should be >= left"), this.X_ = t, this.K_ = i;
    }
    Os() {
      return this.X_;
    }
    ui() {
      return this.K_;
    }
    G_() {
      return this.K_ - this.X_ + 1;
    }
    Kr(t) {
      return this.X_ <= t && t <= this.K_;
    }
    Ch(t) {
      return this.X_ === t.Os() && this.K_ === t.ui();
    }
  };
  function Sn(t, i) {
    return null === t || null === i ? t === i : t.Ch(i);
  }
  var kn = class {
    constructor() {
      this.J_ = /* @__PURE__ */ new Map(), this.tr = null, this.Q_ = false;
    }
    tu(t) {
      this.Q_ = t, this.tr = null;
    }
    iu(t, i) {
      this.nu(i), this.tr = null;
      for (let n = i; n < t.length; ++n) {
        const i2 = t[n];
        let s = this.J_.get(i2.timeWeight);
        void 0 === s && (s = [], this.J_.set(i2.timeWeight, s)), s.push({ index: n, time: i2.time, weight: i2.timeWeight, originalTime: i2.originalTime });
      }
    }
    su(t, i) {
      const n = Math.ceil(i / t);
      return null !== this.tr && this.tr.eu === n || (this.tr = { Ha: this.ru(n), eu: n }), this.tr.Ha;
    }
    nu(t) {
      if (0 === t)
        return void this.J_.clear();
      const i = [];
      this.J_.forEach((n, s) => {
        t <= n[0].index ? i.push(s) : n.splice(Bt(n, t, (i2) => i2.index < t), 1 / 0);
      });
      for (const t2 of i)
        this.J_.delete(t2);
    }
    ru(t) {
      let i = [];
      for (const n of Array.from(this.J_.keys()).sort((t2, i2) => i2 - t2)) {
        if (!this.J_.get(n))
          continue;
        const s = i;
        i = [];
        const e2 = s.length;
        let r2 = 0;
        const h2 = m(this.J_.get(n)), l2 = h2.length;
        let a2 = 1 / 0, o2 = -1 / 0;
        for (let n2 = 0; n2 < l2; n2++) {
          const l3 = h2[n2], _2 = l3.index;
          for (; r2 < e2; ) {
            const t2 = s[r2], n3 = t2.index;
            if (!(n3 < _2)) {
              a2 = n3;
              break;
            }
            r2++, i.push(t2), o2 = n3, a2 = 1 / 0;
          }
          if (a2 - _2 >= t && _2 - o2 >= t)
            i.push(l3), o2 = _2;
          else if (this.Q_)
            return s;
        }
        for (; r2 < e2; r2++)
          i.push(s[r2]);
      }
      return i;
    }
  };
  var yn = class _yn {
    constructor(t) {
      this.hu = t;
    }
    lu() {
      return null === this.hu ? null : new xn(Math.floor(this.hu.Os()), Math.ceil(this.hu.ui()));
    }
    au() {
      return this.hu;
    }
    static ou() {
      return new _yn(null);
    }
  };
  function Cn(t, i) {
    return t.weight > i.weight ? t : i;
  }
  var Tn = class {
    constructor(t, i, n, s) {
      this.__ = 0, this._u = null, this.uu = [], this.Mo = null, this.wo = null, this.cu = new kn(), this.du = /* @__PURE__ */ new Map(), this.fu = yn.ou(), this.vu = true, this.pu = new D(), this.mu = new D(), this.bu = new D(), this.wu = null, this.gu = null, this.Mu = [], this.cn = i, this.yo = n, this.xu = i.rightOffset, this.Su = i.barSpacing, this.$i = t, this.q_ = s, this.ku(), this.cu.tu(i.uniformDistribution);
    }
    W() {
      return this.cn;
    }
    yu(t) {
      V(this.yo, t), this.Cu(), this.ku();
    }
    $h(t, i) {
      var n;
      V(this.cn, t), this.cn.fixLeftEdge && this.Tu(), this.cn.fixRightEdge && this.Pu(), void 0 !== t.barSpacing && this.$i.Gn(t.barSpacing), void 0 !== t.rightOffset && this.$i.Jn(t.rightOffset), void 0 !== t.minBarSpacing && this.$i.Gn(null !== (n = t.barSpacing) && void 0 !== n ? n : this.Su), this.Cu(), this.ku(), this.bu.m();
    }
    mn(t) {
      var i, n;
      return null !== (n = null === (i = this.uu[t]) || void 0 === i ? void 0 : i.time) && void 0 !== n ? n : null;
    }
    Ui(t) {
      var i;
      return null !== (i = this.uu[t]) && void 0 !== i ? i : null;
    }
    Va(t, i) {
      if (this.uu.length < 1)
        return null;
      if (this.q_.key(t) > this.q_.key(this.uu[this.uu.length - 1].time))
        return i ? this.uu.length - 1 : null;
      const n = Bt(this.uu, this.q_.key(t), (t2, i2) => this.q_.key(t2.time) < i2);
      return this.q_.key(t) < this.q_.key(this.uu[n].time) ? i ? n : null : n;
    }
    Ni() {
      return 0 === this.__ || 0 === this.uu.length || null === this._u;
    }
    Da() {
      return this.uu.length > 0;
    }
    Xs() {
      return this.Ru(), this.fu.lu();
    }
    Du() {
      return this.Ru(), this.fu.au();
    }
    Vu() {
      const t = this.Xs();
      if (null === t)
        return null;
      const i = { from: t.Os(), to: t.ui() };
      return this.Ou(i);
    }
    Ou(t) {
      const i = Math.round(t.from), n = Math.round(t.to), s = b(this.Bu()), e2 = b(this.Au());
      return { from: b(this.Ui(Math.max(s, i))), to: b(this.Ui(Math.min(e2, n))) };
    }
    Iu(t) {
      return { from: b(this.Va(t.from, true)), to: b(this.Va(t.to, true)) };
    }
    Hi() {
      return this.__;
    }
    S_(t) {
      if (!isFinite(t) || t <= 0)
        return;
      if (this.__ === t)
        return;
      const i = this.Du(), n = this.__;
      if (this.__ = t, this.vu = true, this.cn.lockVisibleTimeRangeOnResize && 0 !== n) {
        const i2 = this.Su * t / n;
        this.Su = i2;
      }
      if (this.cn.fixLeftEdge && null !== i && i.Os() <= 0) {
        const i2 = n - t;
        this.xu -= Math.round(i2 / this.Su) + 1, this.vu = true;
      }
      this.zu(), this.Lu();
    }
    It(t) {
      if (this.Ni() || !B(t))
        return 0;
      const i = this.Eu() + this.xu - t;
      return this.__ - (i + 0.5) * this.Su - 1;
    }
    Qs(t, i) {
      const n = this.Eu(), s = void 0 === i ? 0 : i.from, e2 = void 0 === i ? t.length : i.to;
      for (let i2 = s; i2 < e2; i2++) {
        const s2 = t[i2].ot, e3 = n + this.xu - s2, r2 = this.__ - (e3 + 0.5) * this.Su - 1;
        t[i2].nt = r2;
      }
    }
    Nu(t) {
      return Math.ceil(this.Fu(t));
    }
    Jn(t) {
      this.vu = true, this.xu = t, this.Lu(), this.$i.Wu(), this.$i.Uh();
    }
    le() {
      return this.Su;
    }
    Gn(t) {
      this.ju(t), this.Lu(), this.$i.Wu(), this.$i.Uh();
    }
    Hu() {
      return this.xu;
    }
    Ha() {
      if (this.Ni())
        return null;
      if (null !== this.gu)
        return this.gu;
      const t = this.Su, i = 5 * (this.$i.W().layout.fontSize + 4) / 8 * (this.cn.tickMarkMaxCharacterLength || 8), n = Math.round(i / t), s = b(this.Xs()), e2 = Math.max(s.Os(), s.Os() - n), r2 = Math.max(s.ui(), s.ui() - n), h2 = this.cu.su(t, i), l2 = this.Bu() + n, a2 = this.Au() - n, o2 = this.$u(), _2 = this.cn.fixLeftEdge || o2, u2 = this.cn.fixRightEdge || o2;
      let c2 = 0;
      for (const t2 of h2) {
        if (!(e2 <= t2.index && t2.index <= r2))
          continue;
        let n2;
        c2 < this.Mu.length ? (n2 = this.Mu[c2], n2.coord = this.It(t2.index), n2.label = this.Uu(t2), n2.weight = t2.weight) : (n2 = { needAlignCoordinate: false, coord: this.It(t2.index), label: this.Uu(t2), weight: t2.weight }, this.Mu.push(n2)), this.Su > i / 2 && !o2 ? n2.needAlignCoordinate = false : n2.needAlignCoordinate = _2 && t2.index <= l2 || u2 && t2.index >= a2, c2++;
      }
      return this.Mu.length = c2, this.gu = this.Mu, this.Mu;
    }
    qu() {
      this.vu = true, this.Gn(this.cn.barSpacing), this.Jn(this.cn.rightOffset);
    }
    Yu(t) {
      this.vu = true, this._u = t, this.Lu(), this.Tu();
    }
    Zu(t, i) {
      const n = this.Fu(t), s = this.le(), e2 = s + i * (s / 10);
      this.Gn(e2), this.cn.rightBarStaysOnScroll || this.Jn(this.Hu() + (n - this.Fu(t)));
    }
    Go(t) {
      this.Mo && this.n_(), null === this.wo && null === this.wu && (this.Ni() || (this.wo = t, this.Xu()));
    }
    Jo(t) {
      if (null === this.wu)
        return;
      const i = kt(this.__ - t, 0, this.__), n = kt(this.__ - b(this.wo), 0, this.__);
      0 !== i && 0 !== n && this.Gn(this.wu.le * i / n);
    }
    Qo() {
      null !== this.wo && (this.wo = null, this.Ku());
    }
    t_(t) {
      null === this.Mo && null === this.wu && (this.Ni() || (this.Mo = t, this.Xu()));
    }
    i_(t) {
      if (null === this.Mo)
        return;
      const i = (this.Mo - t) / this.le();
      this.xu = b(this.wu).Hu + i, this.vu = true, this.Lu();
    }
    n_() {
      null !== this.Mo && (this.Mo = null, this.Ku());
    }
    Gu() {
      this.Ju(this.cn.rightOffset);
    }
    Ju(t, i = 400) {
      if (!isFinite(t))
        throw new RangeError("offset is required and must be finite number");
      if (!isFinite(i) || i <= 0)
        throw new RangeError("animationDuration (optional) must be finite positive number");
      const n = this.xu, s = performance.now();
      this.$i.Zn({ Qu: (t2) => (t2 - s) / i >= 1, tc: (e2) => {
        const r2 = (e2 - s) / i;
        return r2 >= 1 ? t : n + (t - n) * r2;
      } });
    }
    bt(t, i) {
      this.vu = true, this.uu = t, this.cu.iu(t, i), this.Lu();
    }
    nc() {
      return this.pu;
    }
    sc() {
      return this.mu;
    }
    ec() {
      return this.bu;
    }
    Eu() {
      return this._u || 0;
    }
    rc(t) {
      const i = t.G_();
      this.ju(this.__ / i), this.xu = t.ui() - this.Eu(), this.Lu(), this.vu = true, this.$i.Wu(), this.$i.Uh();
    }
    hc() {
      const t = this.Bu(), i = this.Au();
      null !== t && null !== i && this.rc(new xn(t, i + this.cn.rightOffset));
    }
    lc(t) {
      const i = new xn(t.from, t.to);
      this.rc(i);
    }
    qi(t) {
      return void 0 !== this.yo.timeFormatter ? this.yo.timeFormatter(t.originalTime) : this.q_.formatHorzItem(t.time);
    }
    $u() {
      const { handleScroll: t, handleScale: i } = this.$i.W();
      return !(t.horzTouchDrag || t.mouseWheel || t.pressedMouseMove || t.vertTouchDrag || i.axisDoubleClickReset.time || i.axisPressedMouseMove.time || i.mouseWheel || i.pinch);
    }
    Bu() {
      return 0 === this.uu.length ? null : 0;
    }
    Au() {
      return 0 === this.uu.length ? null : this.uu.length - 1;
    }
    ac(t) {
      return (this.__ - 1 - t) / this.Su;
    }
    Fu(t) {
      const i = this.ac(t), n = this.Eu() + this.xu - i;
      return Math.round(1e6 * n) / 1e6;
    }
    ju(t) {
      const i = this.Su;
      this.Su = t, this.zu(), i !== this.Su && (this.vu = true, this.oc());
    }
    Ru() {
      if (!this.vu)
        return;
      if (this.vu = false, this.Ni())
        return void this._c(yn.ou());
      const t = this.Eu(), i = this.__ / this.Su, n = this.xu + t, s = new xn(n - i + 1, n);
      this._c(new yn(s));
    }
    zu() {
      const t = this.uc();
      if (this.Su < t && (this.Su = t, this.vu = true), 0 !== this.__) {
        const t2 = 0.5 * this.__;
        this.Su > t2 && (this.Su = t2, this.vu = true);
      }
    }
    uc() {
      return this.cn.fixLeftEdge && this.cn.fixRightEdge && 0 !== this.uu.length ? this.__ / this.uu.length : this.cn.minBarSpacing;
    }
    Lu() {
      const t = this.cc();
      null !== t && this.xu < t && (this.xu = t, this.vu = true);
      const i = this.dc();
      this.xu > i && (this.xu = i, this.vu = true);
    }
    cc() {
      const t = this.Bu(), i = this._u;
      if (null === t || null === i)
        return null;
      return t - i - 1 + (this.cn.fixLeftEdge ? this.__ / this.Su : Math.min(2, this.uu.length));
    }
    dc() {
      return this.cn.fixRightEdge ? 0 : this.__ / this.Su - Math.min(2, this.uu.length);
    }
    Xu() {
      this.wu = { le: this.le(), Hu: this.Hu() };
    }
    Ku() {
      this.wu = null;
    }
    Uu(t) {
      let i = this.du.get(t.weight);
      return void 0 === i && (i = new Mn((t2) => this.fc(t2), this.q_), this.du.set(t.weight, i)), i.Y_(t);
    }
    fc(t) {
      return this.q_.formatTickmark(t, this.yo);
    }
    _c(t) {
      const i = this.fu;
      this.fu = t, Sn(i.lu(), this.fu.lu()) || this.pu.m(), Sn(i.au(), this.fu.au()) || this.mu.m(), this.oc();
    }
    oc() {
      this.gu = null;
    }
    Cu() {
      this.oc(), this.du.clear();
    }
    ku() {
      this.q_.updateFormatter(this.yo);
    }
    Tu() {
      if (!this.cn.fixLeftEdge)
        return;
      const t = this.Bu();
      if (null === t)
        return;
      const i = this.Xs();
      if (null === i)
        return;
      const n = i.Os() - t;
      if (n < 0) {
        const t2 = this.xu - n - 1;
        this.Jn(t2);
      }
      this.zu();
    }
    Pu() {
      this.Lu(), this.zu();
    }
  };
  var Pn = class {
    X(t, i, n) {
      t.useMediaCoordinateSpace((t2) => this.K(t2, i, n));
    }
    gl(t, i, n) {
      t.useMediaCoordinateSpace((t2) => this.vc(t2, i, n));
    }
    vc(t, i, n) {
    }
  };
  var Rn = class extends Pn {
    constructor(t) {
      super(), this.mc = /* @__PURE__ */ new Map(), this.zt = t;
    }
    K(t) {
    }
    vc(t) {
      if (!this.zt.yt)
        return;
      const { context: i, mediaSize: n } = t;
      let s = 0;
      for (const t2 of this.zt.bc) {
        if (0 === t2.Kt.length)
          continue;
        i.font = t2.R;
        const e3 = this.wc(i, t2.Kt);
        e3 > n.width ? t2.Zu = n.width / e3 : t2.Zu = 1, s += t2.gc * t2.Zu;
      }
      let e2 = 0;
      switch (this.zt.Mc) {
        case "top":
          e2 = 0;
          break;
        case "center":
          e2 = Math.max((n.height - s) / 2, 0);
          break;
        case "bottom":
          e2 = Math.max(n.height - s, 0);
      }
      i.fillStyle = this.zt.V;
      for (const t2 of this.zt.bc) {
        i.save();
        let s2 = 0;
        switch (this.zt.xc) {
          case "left":
            i.textAlign = "left", s2 = t2.gc / 2;
            break;
          case "center":
            i.textAlign = "center", s2 = n.width / 2;
            break;
          case "right":
            i.textAlign = "right", s2 = n.width - 1 - t2.gc / 2;
        }
        i.translate(s2, e2), i.textBaseline = "top", i.font = t2.R, i.scale(t2.Zu, t2.Zu), i.fillText(t2.Kt, 0, t2.Sc), i.restore(), e2 += t2.gc * t2.Zu;
      }
    }
    wc(t, i) {
      const n = this.kc(t.font);
      let s = n.get(i);
      return void 0 === s && (s = t.measureText(i).width, n.set(i, s)), s;
    }
    kc(t) {
      let i = this.mc.get(t);
      return void 0 === i && (i = /* @__PURE__ */ new Map(), this.mc.set(t, i)), i;
    }
  };
  var Dn = class {
    constructor(t) {
      this.ft = true, this.Ft = { yt: false, V: "", bc: [], Mc: "center", xc: "center" }, this.Wt = new Rn(this.Ft), this.jt = t;
    }
    bt() {
      this.ft = true;
    }
    gt() {
      return this.ft && (this.Mt(), this.ft = false), this.Wt;
    }
    Mt() {
      const t = this.jt.W(), i = this.Ft;
      i.yt = t.visible, i.yt && (i.V = t.color, i.xc = t.horzAlign, i.Mc = t.vertAlign, i.bc = [{ Kt: t.text, R: F(t.fontSize, t.fontFamily, t.fontStyle), gc: 1.2 * t.fontSize, Sc: 0, Zu: 0 }]);
    }
  };
  var Vn = class extends lt {
    constructor(t, i) {
      super(), this.cn = i, this.wn = new Dn(this);
    }
    Rn() {
      return [];
    }
    Pn() {
      return [this.wn];
    }
    W() {
      return this.cn;
    }
    Vn() {
      this.wn.bt();
    }
  };
  var On;
  var Bn;
  var An;
  var In;
  var zn;
  !function(t) {
    t[t.OnTouchEnd = 0] = "OnTouchEnd", t[t.OnNextTap = 1] = "OnNextTap";
  }(On || (On = {}));
  var Ln = class {
    constructor(t, i, n) {
      this.yc = [], this.Cc = [], this.__ = 0, this.Tc = null, this.Pc = new D(), this.Rc = new D(), this.Dc = null, this.Vc = t, this.cn = i, this.q_ = n, this.Oc = new W(this), this.yl = new Tn(this, i.timeScale, this.cn.localization, n), this.vt = new ot(this, i.crosshair), this.Bc = new Ji(i.crosshair), this.Ac = new Vn(this, i.watermark), this.Ic(), this.yc[0].x_(2e3), this.zc = this.Lc(0), this.Ec = this.Lc(1);
    }
    Kl() {
      this.Nc(ut.es());
    }
    Uh() {
      this.Nc(ut.ss());
    }
    oa() {
      this.Nc(new ut(1));
    }
    Gl(t) {
      const i = this.Fc(t);
      this.Nc(i);
    }
    Wc() {
      return this.Tc;
    }
    jc(t) {
      const i = this.Tc;
      this.Tc = t, null !== i && this.Gl(i.Hc), null !== t && this.Gl(t.Hc);
    }
    W() {
      return this.cn;
    }
    $h(t) {
      V(this.cn, t), this.yc.forEach((i) => i.b_(t)), void 0 !== t.timeScale && this.yl.$h(t.timeScale), void 0 !== t.localization && this.yl.yu(t.localization), (t.leftPriceScale || t.rightPriceScale) && this.Pc.m(), this.zc = this.Lc(0), this.Ec = this.Lc(1), this.Kl();
    }
    $c(t, i) {
      if ("left" === t)
        return void this.$h({ leftPriceScale: i });
      if ("right" === t)
        return void this.$h({ rightPriceScale: i });
      const n = this.Uc(t);
      null !== n && (n.Dt.$h(i), this.Pc.m());
    }
    Uc(t) {
      for (const i of this.yc) {
        const n = i.w_(t);
        if (null !== n)
          return { Ht: i, Dt: n };
      }
      return null;
    }
    St() {
      return this.yl;
    }
    qc() {
      return this.yc;
    }
    Yc() {
      return this.Ac;
    }
    Zc() {
      return this.vt;
    }
    Xc() {
      return this.Rc;
    }
    Kc(t, i) {
      t.Lo(i), this.Wu();
    }
    S_(t) {
      this.__ = t, this.yl.S_(this.__), this.yc.forEach((i) => i.S_(t)), this.Wu();
    }
    Ic(t) {
      const i = new gn(this.yl, this);
      void 0 !== t ? this.yc.splice(t, 0, i) : this.yc.push(i);
      const n = void 0 === t ? this.yc.length - 1 : t, s = ut.es();
      return s.Nn(n, { Fn: 0, Wn: true }), this.Nc(s), i;
    }
    V_(t, i, n) {
      t.V_(i, n);
    }
    O_(t, i, n) {
      t.O_(i, n), this.Jl(), this.Nc(this.Gc(t, 2));
    }
    B_(t, i) {
      t.B_(i), this.Nc(this.Gc(t, 2));
    }
    A_(t, i, n) {
      i.Vo() || t.A_(i, n);
    }
    I_(t, i, n) {
      i.Vo() || (t.I_(i, n), this.Jl(), this.Nc(this.Gc(t, 2)));
    }
    z_(t, i) {
      i.Vo() || (t.z_(i), this.Nc(this.Gc(t, 2)));
    }
    E_(t, i) {
      t.E_(i), this.Nc(this.Gc(t, 2));
    }
    Jc(t) {
      this.yl.Go(t);
    }
    Qc(t, i) {
      const n = this.St();
      if (n.Ni() || 0 === i)
        return;
      const s = n.Hi();
      t = Math.max(1, Math.min(t, s)), n.Zu(t, i), this.Wu();
    }
    td(t) {
      this.nd(0), this.sd(t), this.ed();
    }
    rd(t) {
      this.yl.Jo(t), this.Wu();
    }
    hd() {
      this.yl.Qo(), this.Uh();
    }
    nd(t) {
      this.yl.t_(t);
    }
    sd(t) {
      this.yl.i_(t), this.Wu();
    }
    ed() {
      this.yl.n_(), this.Uh();
    }
    wt() {
      return this.Cc;
    }
    ld(t, i, n, s, e2) {
      this.vt.gn(t, i);
      let r2 = NaN, h2 = this.yl.Nu(t);
      const l2 = this.yl.Xs();
      null !== l2 && (h2 = Math.min(Math.max(l2.Os(), h2), l2.ui()));
      const a2 = s.vn(), o2 = a2.Ct();
      null !== o2 && (r2 = a2.pn(i, o2)), r2 = this.Bc.Oa(r2, h2, s), this.vt.kn(h2, r2, s), this.oa(), e2 || this.Rc.m(this.vt.xt(), { x: t, y: i }, n);
    }
    ad(t, i, n) {
      const s = n.vn(), e2 = s.Ct(), r2 = s.Rt(t, b(e2)), h2 = this.yl.Va(i, true), l2 = this.yl.It(b(h2));
      this.ld(l2, r2, null, n, true);
    }
    od(t) {
      this.Zc().Cn(), this.oa(), t || this.Rc.m(null, null, null);
    }
    Jl() {
      const t = this.vt.Ht();
      if (null !== t) {
        const i = this.vt.xn(), n = this.vt.Sn();
        this.ld(i, n, null, t);
      }
      this.vt.Vn();
    }
    _d(t, i, n) {
      const s = this.yl.mn(0);
      void 0 !== i && void 0 !== n && this.yl.bt(i, n);
      const e2 = this.yl.mn(0), r2 = this.yl.Eu(), h2 = this.yl.Xs();
      if (null !== h2 && null !== s && null !== e2) {
        const i2 = h2.Kr(r2), l2 = this.q_.key(s) > this.q_.key(e2), a2 = null !== t && t > r2 && !l2, o2 = this.yl.W().allowShiftVisibleRangeOnWhitespaceReplacement, _2 = i2 && (!(void 0 === n) || o2) && this.yl.W().shiftVisibleRangeOnNewBar;
        if (a2 && !_2) {
          const i3 = t - r2;
          this.yl.Jn(this.yl.Hu() - i3);
        }
      }
      this.yl.Yu(t);
    }
    ia(t) {
      null !== t && t.F_();
    }
    dr(t) {
      const i = this.yc.find((i2) => i2.Uo().includes(t));
      return void 0 === i ? null : i;
    }
    Wu() {
      this.Ac.Vn(), this.yc.forEach((t) => t.F_()), this.Jl();
    }
    S() {
      this.yc.forEach((t) => t.S()), this.yc.length = 0, this.cn.localization.priceFormatter = void 0, this.cn.localization.percentageFormatter = void 0, this.cn.localization.timeFormatter = void 0;
    }
    ud() {
      return this.Oc;
    }
    br() {
      return this.Oc.W();
    }
    g_() {
      return this.Pc;
    }
    dd(t, i, n) {
      const s = this.yc[0], e2 = this.fd(i, t, s, n);
      return this.Cc.push(e2), 1 === this.Cc.length ? this.Kl() : this.Uh(), e2;
    }
    vd(t) {
      const i = this.dr(t), n = this.Cc.indexOf(t);
      p(-1 !== n, "Series not found"), this.Cc.splice(n, 1), b(i).Zo(t), t.S && t.S();
    }
    Xl(t, i) {
      const n = b(this.dr(t));
      n.Zo(t);
      const s = this.Uc(i);
      if (null === s) {
        const s2 = t.Xi();
        n.qo(t, i, s2);
      } else {
        const e2 = s.Ht === n ? t.Xi() : void 0;
        s.Ht.qo(t, i, e2);
      }
    }
    hc() {
      const t = ut.ss();
      t.$n(), this.Nc(t);
    }
    pd(t) {
      const i = ut.ss();
      i.Yn(t), this.Nc(i);
    }
    Kn() {
      const t = ut.ss();
      t.Kn(), this.Nc(t);
    }
    Gn(t) {
      const i = ut.ss();
      i.Gn(t), this.Nc(i);
    }
    Jn(t) {
      const i = ut.ss();
      i.Jn(t), this.Nc(i);
    }
    Zn(t) {
      const i = ut.ss();
      i.Zn(t), this.Nc(i);
    }
    Un() {
      const t = ut.ss();
      t.Un(), this.Nc(t);
    }
    md() {
      return this.cn.rightPriceScale.visible ? "right" : "left";
    }
    bd() {
      return this.Ec;
    }
    q() {
      return this.zc;
    }
    Bt(t) {
      const i = this.Ec, n = this.zc;
      if (i === n)
        return i;
      if (t = Math.max(0, Math.min(100, Math.round(100 * t))), null === this.Dc || this.Dc.Ps !== n || this.Dc.Rs !== i)
        this.Dc = { Ps: n, Rs: i, wd: /* @__PURE__ */ new Map() };
      else {
        const i2 = this.Dc.wd.get(t);
        if (void 0 !== i2)
          return i2;
      }
      const s = function(t2, i2, n2) {
        const [s2, e2, r2, h2] = T(t2), [l2, a2, o2, _2] = T(i2), u2 = [M(s2 + n2 * (l2 - s2)), M(e2 + n2 * (a2 - e2)), M(r2 + n2 * (o2 - r2)), x(h2 + n2 * (_2 - h2))];
        return `rgba(${u2[0]}, ${u2[1]}, ${u2[2]}, ${u2[3]})`;
      }(n, i, t / 100);
      return this.Dc.wd.set(t, s), s;
    }
    Gc(t, i) {
      const n = new ut(i);
      if (null !== t) {
        const s = this.yc.indexOf(t);
        n.Nn(s, { Fn: i });
      }
      return n;
    }
    Fc(t, i) {
      return void 0 === i && (i = 2), this.Gc(this.dr(t), i);
    }
    Nc(t) {
      this.Vc && this.Vc(t), this.yc.forEach((t2) => t2.j_().qh().bt());
    }
    fd(t, i, n, s) {
      const e2 = new Gi(this, t, i, n, s), r2 = void 0 !== t.priceScaleId ? t.priceScaleId : this.md();
      return n.qo(e2, r2), _t(r2) || e2.$h(t), e2;
    }
    Lc(t) {
      const i = this.cn.layout;
      return "gradient" === i.background.type ? 0 === t ? i.background.topColor : i.background.bottomColor : i.background.color;
    }
  };
  function En(t) {
    return !O(t) && !A(t);
  }
  function Nn(t) {
    return O(t);
  }
  !function(t) {
    t[t.Disabled = 0] = "Disabled", t[t.Continuous = 1] = "Continuous", t[t.OnDataUpdate = 2] = "OnDataUpdate";
  }(Bn || (Bn = {})), function(t) {
    t[t.LastBar = 0] = "LastBar", t[t.LastVisible = 1] = "LastVisible";
  }(An || (An = {})), function(t) {
    t.Solid = "solid", t.VerticalGradient = "gradient";
  }(In || (In = {})), function(t) {
    t[t.Year = 0] = "Year", t[t.Month = 1] = "Month", t[t.DayOfMonth = 2] = "DayOfMonth", t[t.Time = 3] = "Time", t[t.TimeWithSeconds = 4] = "TimeWithSeconds";
  }(zn || (zn = {}));
  var Fn = (t) => t.getUTCFullYear();
  function Wn(t, i, n) {
    return i.replace(/yyyy/g, ((t2) => dt(Fn(t2), 4))(t)).replace(/yy/g, ((t2) => dt(Fn(t2) % 100, 2))(t)).replace(/MMMM/g, ((t2, i2) => new Date(t2.getUTCFullYear(), t2.getUTCMonth(), 1).toLocaleString(i2, { month: "long" }))(t, n)).replace(/MMM/g, ((t2, i2) => new Date(t2.getUTCFullYear(), t2.getUTCMonth(), 1).toLocaleString(i2, { month: "short" }))(t, n)).replace(/MM/g, ((t2) => dt(((t3) => t3.getUTCMonth() + 1)(t2), 2))(t)).replace(/dd/g, ((t2) => dt(((t3) => t3.getUTCDate())(t2), 2))(t));
  }
  var jn = class {
    constructor(t = "yyyy-MM-dd", i = "default") {
      this.gd = t, this.Md = i;
    }
    Y_(t) {
      return Wn(t, this.gd, this.Md);
    }
  };
  var Hn = class {
    constructor(t) {
      this.xd = t || "%h:%m:%s";
    }
    Y_(t) {
      return this.xd.replace("%h", dt(t.getUTCHours(), 2)).replace("%m", dt(t.getUTCMinutes(), 2)).replace("%s", dt(t.getUTCSeconds(), 2));
    }
  };
  var $n = { Sd: "yyyy-MM-dd", kd: "%h:%m:%s", yd: " ", Cd: "default" };
  var Un = class {
    constructor(t = {}) {
      const i = Object.assign(Object.assign({}, $n), t);
      this.Td = new jn(i.Sd, i.Cd), this.Pd = new Hn(i.kd), this.Rd = i.yd;
    }
    Y_(t) {
      return `${this.Td.Y_(t)}${this.Rd}${this.Pd.Y_(t)}`;
    }
  };
  function qn(t) {
    return 60 * t * 60 * 1e3;
  }
  function Yn(t) {
    return 60 * t * 1e3;
  }
  var Zn = [{ Dd: (Xn = 1, 1e3 * Xn), Vd: 10 }, { Dd: Yn(1), Vd: 20 }, { Dd: Yn(5), Vd: 21 }, { Dd: Yn(30), Vd: 22 }, { Dd: qn(1), Vd: 30 }, { Dd: qn(3), Vd: 31 }, { Dd: qn(6), Vd: 32 }, { Dd: qn(12), Vd: 33 }];
  var Xn;
  function Kn(t, i) {
    if (t.getUTCFullYear() !== i.getUTCFullYear())
      return 70;
    if (t.getUTCMonth() !== i.getUTCMonth())
      return 60;
    if (t.getUTCDate() !== i.getUTCDate())
      return 50;
    for (let n = Zn.length - 1; n >= 0; --n)
      if (Math.floor(i.getTime() / Zn[n].Dd) !== Math.floor(t.getTime() / Zn[n].Dd))
        return Zn[n].Vd;
    return 0;
  }
  function Gn(t) {
    let i = t;
    if (A(t) && (i = Qn(t)), !En(i))
      throw new Error("time must be of type BusinessDay");
    const n = new Date(Date.UTC(i.year, i.month - 1, i.day, 0, 0, 0, 0));
    return { Od: Math.round(n.getTime() / 1e3), Bd: i };
  }
  function Jn(t) {
    if (!Nn(t))
      throw new Error("time must be of type isUTCTimestamp");
    return { Od: t };
  }
  function Qn(t) {
    const i = new Date(t);
    if (isNaN(i.getTime()))
      throw new Error(`Invalid date string=${t}, expected format=yyyy-mm-dd`);
    return { day: i.getUTCDate(), month: i.getUTCMonth() + 1, year: i.getUTCFullYear() };
  }
  function ts(t) {
    A(t.time) && (t.time = Qn(t.time));
  }
  var is = class {
    options() {
      return this.cn;
    }
    setOptions(t) {
      this.cn = t, this.updateFormatter(t.localization);
    }
    preprocessData(t) {
      Array.isArray(t) ? function(t2) {
        t2.forEach(ts);
      }(t) : ts(t);
    }
    createConverterToInternalObj(t) {
      return b(function(t2) {
        return 0 === t2.length ? null : En(t2[0].time) || A(t2[0].time) ? Gn : Jn;
      }(t));
    }
    key(t) {
      return "object" == typeof t && "Od" in t ? t.Od : this.key(this.convertHorzItemToInternal(t));
    }
    cacheKey(t) {
      const i = t;
      return void 0 === i.Bd ? new Date(1e3 * i.Od).getTime() : new Date(Date.UTC(i.Bd.year, i.Bd.month - 1, i.Bd.day)).getTime();
    }
    convertHorzItemToInternal(t) {
      return Nn(i = t) ? Jn(i) : En(i) ? Gn(i) : Gn(Qn(i));
      var i;
    }
    updateFormatter(t) {
      if (!this.cn)
        return;
      const i = t.dateFormat;
      this.cn.timeScale.timeVisible ? this.Ad = new Un({ Sd: i, kd: this.cn.timeScale.secondsVisible ? "%h:%m:%s" : "%h:%m", yd: "   ", Cd: t.locale }) : this.Ad = new jn(i, t.locale);
    }
    formatHorzItem(t) {
      const i = t;
      return this.Ad.Y_(new Date(1e3 * i.Od));
    }
    formatTickmark(t, i) {
      const n = function(t2, i2, n2) {
        switch (t2) {
          case 0:
          case 10:
            return i2 ? n2 ? 4 : 3 : 2;
          case 20:
          case 21:
          case 22:
          case 30:
          case 31:
          case 32:
          case 33:
            return i2 ? 3 : 2;
          case 50:
            return 2;
          case 60:
            return 1;
          case 70:
            return 0;
        }
      }(t.weight, this.cn.timeScale.timeVisible, this.cn.timeScale.secondsVisible), s = this.cn.timeScale;
      if (void 0 !== s.tickMarkFormatter) {
        const e2 = s.tickMarkFormatter(t.originalTime, n, i.locale);
        if (null !== e2)
          return e2;
      }
      return function(t2, i2, n2) {
        const s2 = {};
        switch (i2) {
          case 0:
            s2.year = "numeric";
            break;
          case 1:
            s2.month = "short";
            break;
          case 2:
            s2.day = "numeric";
            break;
          case 3:
            s2.hour12 = false, s2.hour = "2-digit", s2.minute = "2-digit";
            break;
          case 4:
            s2.hour12 = false, s2.hour = "2-digit", s2.minute = "2-digit", s2.second = "2-digit";
        }
        const e2 = void 0 === t2.Bd ? new Date(1e3 * t2.Od) : new Date(Date.UTC(t2.Bd.year, t2.Bd.month - 1, t2.Bd.day));
        return new Date(e2.getUTCFullYear(), e2.getUTCMonth(), e2.getUTCDate(), e2.getUTCHours(), e2.getUTCMinutes(), e2.getUTCSeconds(), e2.getUTCMilliseconds()).toLocaleString(n2, s2);
      }(t.time, n, i.locale);
    }
    maxTickMarkWeight(t) {
      let i = t.reduce(Cn, t[0]).weight;
      return i > 30 && i < 50 && (i = 30), i;
    }
    fillWeightsForPoints(t, i) {
      !function(t2, i2 = 0) {
        if (0 === t2.length)
          return;
        let n = 0 === i2 ? null : t2[i2 - 1].time.Od, s = null !== n ? new Date(1e3 * n) : null, e2 = 0;
        for (let r2 = i2; r2 < t2.length; ++r2) {
          const i3 = t2[r2], h2 = new Date(1e3 * i3.time.Od);
          null !== s && (i3.timeWeight = Kn(h2, s)), e2 += i3.time.Od - (n || i3.time.Od), n = i3.time.Od, s = h2;
        }
        if (0 === i2 && t2.length > 1) {
          const i3 = Math.ceil(e2 / (t2.length - 1)), n2 = new Date(1e3 * (t2[0].time.Od - i3));
          t2[0].timeWeight = Kn(new Date(1e3 * t2[0].time.Od), n2);
        }
      }(t, i);
    }
    static Id(t) {
      return V({ localization: { dateFormat: "dd MMM 'yy" } }, null != t ? t : {});
    }
  };
  var ns = "undefined" != typeof window;
  function ss() {
    return !!ns && window.navigator.userAgent.toLowerCase().indexOf("firefox") > -1;
  }
  function es() {
    return !!ns && /iPhone|iPad|iPod/.test(window.navigator.platform);
  }
  function rs(t) {
    return t + t % 2;
  }
  function hs(t, i) {
    return t.zd - i.zd;
  }
  function ls(t, i, n) {
    const s = (t.zd - i.zd) / (t.ot - i.ot);
    return Math.sign(s) * Math.min(Math.abs(s), n);
  }
  var as = class {
    constructor(t, i, n, s) {
      this.Ld = null, this.Ed = null, this.Nd = null, this.Fd = null, this.Wd = null, this.jd = 0, this.Hd = 0, this.$d = t, this.Ud = i, this.qd = n, this.rs = s;
    }
    Yd(t, i) {
      if (null !== this.Ld) {
        if (this.Ld.ot === i)
          return void (this.Ld.zd = t);
        if (Math.abs(this.Ld.zd - t) < this.rs)
          return;
      }
      this.Fd = this.Nd, this.Nd = this.Ed, this.Ed = this.Ld, this.Ld = { ot: i, zd: t };
    }
    Vr(t, i) {
      if (null === this.Ld || null === this.Ed)
        return;
      if (i - this.Ld.ot > 50)
        return;
      let n = 0;
      const s = ls(this.Ld, this.Ed, this.Ud), e2 = hs(this.Ld, this.Ed), r2 = [s], h2 = [e2];
      if (n += e2, null !== this.Nd) {
        const t2 = ls(this.Ed, this.Nd, this.Ud);
        if (Math.sign(t2) === Math.sign(s)) {
          const i2 = hs(this.Ed, this.Nd);
          if (r2.push(t2), h2.push(i2), n += i2, null !== this.Fd) {
            const t3 = ls(this.Nd, this.Fd, this.Ud);
            if (Math.sign(t3) === Math.sign(s)) {
              const i3 = hs(this.Nd, this.Fd);
              r2.push(t3), h2.push(i3), n += i3;
            }
          }
        }
      }
      let l2 = 0;
      for (let t2 = 0; t2 < r2.length; ++t2)
        l2 += h2[t2] / n * r2[t2];
      Math.abs(l2) < this.$d || (this.Wd = { zd: t, ot: i }, this.Hd = l2, this.jd = function(t2, i2) {
        const n2 = Math.log(i2);
        return Math.log(1 * n2 / -t2) / n2;
      }(Math.abs(l2), this.qd));
    }
    tc(t) {
      const i = b(this.Wd), n = t - i.ot;
      return i.zd + this.Hd * (Math.pow(this.qd, n) - 1) / Math.log(this.qd);
    }
    Qu(t) {
      return null === this.Wd || this.Zd(t) === this.jd;
    }
    Zd(t) {
      const i = t - b(this.Wd).ot;
      return Math.min(i, this.jd);
    }
  };
  var os = class {
    constructor(t, i) {
      this.Xd = void 0, this.Kd = void 0, this.Gd = void 0, this.en = false, this.Jd = t, this.Qd = i, this.tf();
    }
    bt() {
      this.tf();
    }
    if() {
      this.Xd && this.Jd.removeChild(this.Xd), this.Kd && this.Jd.removeChild(this.Kd), this.Xd = void 0, this.Kd = void 0;
    }
    nf() {
      return this.en !== this.sf() || this.Gd !== this.ef();
    }
    ef() {
      return P(T(this.Qd.W().layout.textColor)) > 160 ? "dark" : "light";
    }
    sf() {
      return this.Qd.W().layout.attributionLogo;
    }
    rf() {
      const t = new URL(location.href);
      return t.hostname ? "&utm_source=" + t.hostname + t.pathname : "";
    }
    tf() {
      this.nf() && (this.if(), this.en = this.sf(), this.en && (this.Gd = this.ef(), this.Kd = document.createElement("style"), this.Kd.innerText = "a#tv-attr-logo{--fill:#131722;--stroke:#fff;position:absolute;left:10px;bottom:10px;height:19px;width:35px;margin:0;padding:0;border:0;z-index:3;}a#tv-attr-logo[data-dark]{--fill:#D1D4DC;--stroke:#131722;}", this.Xd = document.createElement("a"), this.Xd.href = `https://www.tradingview.com/?utm_medium=lwc-link&utm_campaign=lwc-chart${this.rf()}`, this.Xd.title = "Charting by TradingView", this.Xd.id = "tv-attr-logo", this.Xd.target = "_blank", this.Xd.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 35 19" width="35" height="19" fill="none"><g fill-rule="evenodd" clip-path="url(#a)" clip-rule="evenodd"><path fill="var(--stroke)" d="M2 0H0v10h6v9h21.4l.5-1.3 6-15 1-2.7H23.7l-.5 1.3-.2.6a5 5 0 0 0-7-.9V0H2Zm20 17h4l5.2-13 .8-2h-7l-1 2.5-.2.5-1.5 3.8-.3.7V17Zm-.8-10a3 3 0 0 0 .7-2.7A3 3 0 1 0 16.8 7h4.4ZM14 7V2H2v6h6v9h4V7h2Z"/><path fill="var(--fill)" d="M14 2H2v6h6v9h6V2Zm12 15h-7l6-15h7l-6 15Zm-7-9a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/></g><defs><clipPath id="a"><path fill="var(--stroke)" d="M0 0h35v19H0z"/></clipPath></defs></svg>', this.Xd.toggleAttribute("data-dark", "dark" === this.Gd), this.Jd.appendChild(this.Kd), this.Jd.appendChild(this.Xd)));
    }
  };
  function _s(t, n) {
    const s = b(t.ownerDocument).createElement("canvas");
    t.appendChild(s);
    const e2 = bindTo(s, { type: "device-pixel-content-box", options: { allowResizeObserver: false }, transform: (t2, i) => ({ width: Math.max(t2.width, i.width), height: Math.max(t2.height, i.height) }) });
    return e2.resizeCanvasElement(n), e2;
  }
  function us(t) {
    var i;
    t.width = 1, t.height = 1, null === (i = t.getContext("2d")) || void 0 === i || i.clearRect(0, 0, 1, 1);
  }
  function cs(t, i, n, s) {
    t.gl && t.gl(i, n, s);
  }
  function ds(t, i, n, s) {
    t.X(i, n, s);
  }
  function fs(t, i, n, s) {
    const e2 = t(n, s);
    for (const t2 of e2) {
      const n2 = t2.gt();
      null !== n2 && i(n2);
    }
  }
  function vs(t) {
    ns && void 0 !== window.chrome && t.addEventListener("mousedown", (t2) => {
      if (1 === t2.button)
        return t2.preventDefault(), false;
    });
  }
  var ps = class {
    constructor(t, i, n) {
      this.hf = 0, this.lf = null, this.af = { nt: Number.NEGATIVE_INFINITY, st: Number.POSITIVE_INFINITY }, this._f = 0, this.uf = null, this.cf = { nt: Number.NEGATIVE_INFINITY, st: Number.POSITIVE_INFINITY }, this.df = null, this.ff = false, this.vf = null, this.pf = null, this.mf = false, this.bf = false, this.wf = false, this.gf = null, this.Mf = null, this.xf = null, this.Sf = null, this.kf = null, this.yf = null, this.Cf = null, this.Tf = 0, this.Pf = false, this.Rf = false, this.Df = false, this.Vf = 0, this.Of = null, this.Bf = !es(), this.Af = (t2) => {
        this.If(t2);
      }, this.zf = (t2) => {
        if (this.Lf(t2)) {
          const i2 = this.Ef(t2);
          if (++this._f, this.uf && this._f > 1) {
            const { Nf: n2 } = this.Ff(ws(t2), this.cf);
            n2 < 30 && !this.wf && this.Wf(i2, this.Hf.jf), this.$f();
          }
        } else {
          const i2 = this.Ef(t2);
          if (++this.hf, this.lf && this.hf > 1) {
            const { Nf: n2 } = this.Ff(ws(t2), this.af);
            n2 < 5 && !this.bf && this.Uf(i2, this.Hf.qf), this.Yf();
          }
        }
      }, this.Zf = t, this.Hf = i, this.cn = n, this.Xf();
    }
    S() {
      null !== this.gf && (this.gf(), this.gf = null), null !== this.Mf && (this.Mf(), this.Mf = null), null !== this.Sf && (this.Sf(), this.Sf = null), null !== this.kf && (this.kf(), this.kf = null), null !== this.yf && (this.yf(), this.yf = null), null !== this.xf && (this.xf(), this.xf = null), this.Kf(), this.Yf();
    }
    Gf(t) {
      this.Sf && this.Sf();
      const i = this.Jf.bind(this);
      if (this.Sf = () => {
        this.Zf.removeEventListener("mousemove", i);
      }, this.Zf.addEventListener("mousemove", i), this.Lf(t))
        return;
      const n = this.Ef(t);
      this.Uf(n, this.Hf.Qf), this.Bf = true;
    }
    Yf() {
      null !== this.lf && clearTimeout(this.lf), this.hf = 0, this.lf = null, this.af = { nt: Number.NEGATIVE_INFINITY, st: Number.POSITIVE_INFINITY };
    }
    $f() {
      null !== this.uf && clearTimeout(this.uf), this._f = 0, this.uf = null, this.cf = { nt: Number.NEGATIVE_INFINITY, st: Number.POSITIVE_INFINITY };
    }
    Jf(t) {
      if (this.Df || null !== this.pf)
        return;
      if (this.Lf(t))
        return;
      const i = this.Ef(t);
      this.Uf(i, this.Hf.tv), this.Bf = true;
    }
    iv(t) {
      const i = Ms(t.changedTouches, b(this.Of));
      if (null === i)
        return;
      if (this.Vf = gs(t), null !== this.Cf)
        return;
      if (this.Rf)
        return;
      this.Pf = true;
      const n = this.Ff(ws(i), b(this.pf)), { nv: s, sv: e2, Nf: r2 } = n;
      if (this.mf || !(r2 < 5)) {
        if (!this.mf) {
          const t2 = 0.5 * s, i2 = e2 >= t2 && !this.cn.ev(), n2 = t2 > e2 && !this.cn.rv();
          i2 || n2 || (this.Rf = true), this.mf = true, this.wf = true, this.Kf(), this.$f();
        }
        if (!this.Rf) {
          const n2 = this.Ef(t, i);
          this.Wf(n2, this.Hf.hv), bs(t);
        }
      }
    }
    lv(t) {
      if (0 !== t.button)
        return;
      const i = this.Ff(ws(t), b(this.vf)), { Nf: n } = i;
      if (n >= 5 && (this.bf = true, this.Yf()), this.bf) {
        const i2 = this.Ef(t);
        this.Uf(i2, this.Hf.av);
      }
    }
    Ff(t, i) {
      const n = Math.abs(i.nt - t.nt), s = Math.abs(i.st - t.st);
      return { nv: n, sv: s, Nf: n + s };
    }
    ov(t) {
      let i = Ms(t.changedTouches, b(this.Of));
      if (null === i && 0 === t.touches.length && (i = t.changedTouches[0]), null === i)
        return;
      this.Of = null, this.Vf = gs(t), this.Kf(), this.pf = null, this.yf && (this.yf(), this.yf = null);
      const n = this.Ef(t, i);
      if (this.Wf(n, this.Hf._v), ++this._f, this.uf && this._f > 1) {
        const { Nf: t2 } = this.Ff(ws(i), this.cf);
        t2 < 30 && !this.wf && this.Wf(n, this.Hf.jf), this.$f();
      } else
        this.wf || (this.Wf(n, this.Hf.uv), this.Hf.uv && bs(t));
      0 === this._f && bs(t), 0 === t.touches.length && this.ff && (this.ff = false, bs(t));
    }
    If(t) {
      if (0 !== t.button)
        return;
      const i = this.Ef(t);
      if (this.vf = null, this.Df = false, this.kf && (this.kf(), this.kf = null), ss()) {
        this.Zf.ownerDocument.documentElement.removeEventListener("mouseleave", this.Af);
      }
      if (!this.Lf(t))
        if (this.Uf(i, this.Hf.cv), ++this.hf, this.lf && this.hf > 1) {
          const { Nf: n } = this.Ff(ws(t), this.af);
          n < 5 && !this.bf && this.Uf(i, this.Hf.qf), this.Yf();
        } else
          this.bf || this.Uf(i, this.Hf.dv);
    }
    Kf() {
      null !== this.df && (clearTimeout(this.df), this.df = null);
    }
    fv(t) {
      if (null !== this.Of)
        return;
      const i = t.changedTouches[0];
      this.Of = i.identifier, this.Vf = gs(t);
      const n = this.Zf.ownerDocument.documentElement;
      this.wf = false, this.mf = false, this.Rf = false, this.pf = ws(i), this.yf && (this.yf(), this.yf = null);
      {
        const i2 = this.iv.bind(this), s2 = this.ov.bind(this);
        this.yf = () => {
          n.removeEventListener("touchmove", i2), n.removeEventListener("touchend", s2);
        }, n.addEventListener("touchmove", i2, { passive: false }), n.addEventListener("touchend", s2, { passive: false }), this.Kf(), this.df = setTimeout(this.vv.bind(this, t), 240);
      }
      const s = this.Ef(t, i);
      this.Wf(s, this.Hf.pv), this.uf || (this._f = 0, this.uf = setTimeout(this.$f.bind(this), 500), this.cf = ws(i));
    }
    mv(t) {
      if (0 !== t.button)
        return;
      const i = this.Zf.ownerDocument.documentElement;
      ss() && i.addEventListener("mouseleave", this.Af), this.bf = false, this.vf = ws(t), this.kf && (this.kf(), this.kf = null);
      {
        const t2 = this.lv.bind(this), n2 = this.If.bind(this);
        this.kf = () => {
          i.removeEventListener("mousemove", t2), i.removeEventListener("mouseup", n2);
        }, i.addEventListener("mousemove", t2), i.addEventListener("mouseup", n2);
      }
      if (this.Df = true, this.Lf(t))
        return;
      const n = this.Ef(t);
      this.Uf(n, this.Hf.bv), this.lf || (this.hf = 0, this.lf = setTimeout(this.Yf.bind(this), 500), this.af = ws(t));
    }
    Xf() {
      this.Zf.addEventListener("mouseenter", this.Gf.bind(this)), this.Zf.addEventListener("touchcancel", this.Kf.bind(this));
      {
        const t = this.Zf.ownerDocument, i = (t2) => {
          this.Hf.wv && (t2.composed && this.Zf.contains(t2.composedPath()[0]) || t2.target && this.Zf.contains(t2.target) || this.Hf.wv());
        };
        this.Mf = () => {
          t.removeEventListener("touchstart", i);
        }, this.gf = () => {
          t.removeEventListener("mousedown", i);
        }, t.addEventListener("mousedown", i), t.addEventListener("touchstart", i, { passive: true });
      }
      es() && (this.xf = () => {
        this.Zf.removeEventListener("dblclick", this.zf);
      }, this.Zf.addEventListener("dblclick", this.zf)), this.Zf.addEventListener("mouseleave", this.gv.bind(this)), this.Zf.addEventListener("touchstart", this.fv.bind(this), { passive: true }), vs(this.Zf), this.Zf.addEventListener("mousedown", this.mv.bind(this)), this.Mv(), this.Zf.addEventListener("touchmove", () => {
      }, { passive: false });
    }
    Mv() {
      void 0 === this.Hf.xv && void 0 === this.Hf.Sv && void 0 === this.Hf.kv || (this.Zf.addEventListener("touchstart", (t) => this.yv(t.touches), { passive: true }), this.Zf.addEventListener("touchmove", (t) => {
        if (2 === t.touches.length && null !== this.Cf && void 0 !== this.Hf.Sv) {
          const i = ms(t.touches[0], t.touches[1]) / this.Tf;
          this.Hf.Sv(this.Cf, i), bs(t);
        }
      }, { passive: false }), this.Zf.addEventListener("touchend", (t) => {
        this.yv(t.touches);
      }));
    }
    yv(t) {
      1 === t.length && (this.Pf = false), 2 !== t.length || this.Pf || this.ff ? this.Cv() : this.Tv(t);
    }
    Tv(t) {
      const i = this.Zf.getBoundingClientRect() || { left: 0, top: 0 };
      this.Cf = { nt: (t[0].clientX - i.left + (t[1].clientX - i.left)) / 2, st: (t[0].clientY - i.top + (t[1].clientY - i.top)) / 2 }, this.Tf = ms(t[0], t[1]), void 0 !== this.Hf.xv && this.Hf.xv(), this.Kf();
    }
    Cv() {
      null !== this.Cf && (this.Cf = null, void 0 !== this.Hf.kv && this.Hf.kv());
    }
    gv(t) {
      if (this.Sf && this.Sf(), this.Lf(t))
        return;
      if (!this.Bf)
        return;
      const i = this.Ef(t);
      this.Uf(i, this.Hf.Pv), this.Bf = !es();
    }
    vv(t) {
      const i = Ms(t.touches, b(this.Of));
      if (null === i)
        return;
      const n = this.Ef(t, i);
      this.Wf(n, this.Hf.Rv), this.wf = true, this.ff = true;
    }
    Lf(t) {
      return t.sourceCapabilities && void 0 !== t.sourceCapabilities.firesTouchEvents ? t.sourceCapabilities.firesTouchEvents : gs(t) < this.Vf + 500;
    }
    Wf(t, i) {
      i && i.call(this.Hf, t);
    }
    Uf(t, i) {
      i && i.call(this.Hf, t);
    }
    Ef(t, i) {
      const n = i || t, s = this.Zf.getBoundingClientRect() || { left: 0, top: 0 };
      return { clientX: n.clientX, clientY: n.clientY, pageX: n.pageX, pageY: n.pageY, screenX: n.screenX, screenY: n.screenY, localX: n.clientX - s.left, localY: n.clientY - s.top, ctrlKey: t.ctrlKey, altKey: t.altKey, shiftKey: t.shiftKey, metaKey: t.metaKey, Dv: !t.type.startsWith("mouse") && "contextmenu" !== t.type && "click" !== t.type, Vv: t.type, Ov: n.target, Bv: t.view, Av: () => {
        "touchstart" !== t.type && bs(t);
      } };
    }
  };
  function ms(t, i) {
    const n = t.clientX - i.clientX, s = t.clientY - i.clientY;
    return Math.sqrt(n * n + s * s);
  }
  function bs(t) {
    t.cancelable && t.preventDefault();
  }
  function ws(t) {
    return { nt: t.pageX, st: t.pageY };
  }
  function gs(t) {
    return t.timeStamp || performance.now();
  }
  function Ms(t, i) {
    for (let n = 0; n < t.length; ++n)
      if (t[n].identifier === i)
        return t[n];
    return null;
  }
  function xs(t) {
    return { Hc: t.Hc, Iv: { gr: t.zv.externalId }, Lv: t.zv.cursorStyle };
  }
  function Ss(t, i, n) {
    for (const s of t) {
      const t2 = s.gt();
      if (null !== t2 && t2.wr) {
        const e2 = t2.wr(i, n);
        if (null !== e2)
          return { Bv: s, Iv: e2 };
      }
    }
    return null;
  }
  function ks(t, i) {
    return (n) => {
      var s, e2, r2, h2;
      return (null !== (e2 = null === (s = n.Dt()) || void 0 === s ? void 0 : s.Pa()) && void 0 !== e2 ? e2 : "") !== i ? [] : null !== (h2 = null === (r2 = n.da) || void 0 === r2 ? void 0 : r2.call(n, t)) && void 0 !== h2 ? h2 : [];
    };
  }
  function ys(t, i, n, s) {
    if (!t.length)
      return;
    let e2 = 0;
    const r2 = n / 2, h2 = t[0].At(s, true);
    let l2 = 1 === i ? r2 - (t[0].Vi() - h2 / 2) : t[0].Vi() - h2 / 2 - r2;
    l2 = Math.max(0, l2);
    for (let r3 = 1; r3 < t.length; r3++) {
      const h3 = t[r3], a2 = t[r3 - 1], o2 = a2.At(s, false), _2 = h3.Vi(), u2 = a2.Vi();
      if (1 === i ? _2 > u2 - o2 : _2 < u2 + o2) {
        const s2 = u2 - o2 * i;
        h3.Oi(s2);
        const r4 = s2 - i * o2 / 2;
        if ((1 === i ? r4 < 0 : r4 > n) && l2 > 0) {
          const s3 = 1 === i ? -1 - r4 : r4 - n, h4 = Math.min(s3, l2);
          for (let n2 = e2; n2 < t.length; n2++)
            t[n2].Oi(t[n2].Vi() + i * h4);
          l2 -= h4;
        }
      } else
        e2 = r3, l2 = 1 === i ? u2 - o2 - _2 : _2 - (u2 + o2);
    }
  }
  var Cs = class {
    constructor(i, n, s, e2) {
      this.Li = null, this.Ev = null, this.Nv = false, this.Fv = new ni(200), this.Qr = null, this.Wv = 0, this.jv = false, this.Hv = () => {
        this.jv || this.tn.$v().$t().Uh();
      }, this.Uv = () => {
        this.jv || this.tn.$v().$t().Uh();
      }, this.tn = i, this.cn = n, this.ko = n.layout, this.Oc = s, this.qv = "left" === e2, this.Yv = ks("normal", e2), this.Zv = ks("top", e2), this.Xv = ks("bottom", e2), this.Kv = document.createElement("div"), this.Kv.style.height = "100%", this.Kv.style.overflow = "hidden", this.Kv.style.width = "25px", this.Kv.style.left = "0", this.Kv.style.position = "relative", this.Gv = _s(this.Kv, size({ width: 16, height: 16 })), this.Gv.subscribeSuggestedBitmapSizeChanged(this.Hv);
      const r2 = this.Gv.canvasElement;
      r2.style.position = "absolute", r2.style.zIndex = "1", r2.style.left = "0", r2.style.top = "0", this.Jv = _s(this.Kv, size({ width: 16, height: 16 })), this.Jv.subscribeSuggestedBitmapSizeChanged(this.Uv);
      const h2 = this.Jv.canvasElement;
      h2.style.position = "absolute", h2.style.zIndex = "2", h2.style.left = "0", h2.style.top = "0";
      const l2 = { bv: this.Qv.bind(this), pv: this.Qv.bind(this), av: this.tp.bind(this), hv: this.tp.bind(this), wv: this.ip.bind(this), cv: this.np.bind(this), _v: this.np.bind(this), qf: this.sp.bind(this), jf: this.sp.bind(this), Qf: this.ep.bind(this), Pv: this.rp.bind(this) };
      this.hp = new ps(this.Jv.canvasElement, l2, { ev: () => !this.cn.handleScroll.vertTouchDrag, rv: () => true });
    }
    S() {
      this.hp.S(), this.Jv.unsubscribeSuggestedBitmapSizeChanged(this.Uv), us(this.Jv.canvasElement), this.Jv.dispose(), this.Gv.unsubscribeSuggestedBitmapSizeChanged(this.Hv), us(this.Gv.canvasElement), this.Gv.dispose(), null !== this.Li && this.Li.Ko().p(this), this.Li = null;
    }
    lp() {
      return this.Kv;
    }
    P() {
      return this.ko.fontSize;
    }
    ap() {
      const t = this.Oc.W();
      return this.Qr !== t.R && (this.Fv.nr(), this.Qr = t.R), t;
    }
    op() {
      if (null === this.Li)
        return 0;
      let t = 0;
      const i = this.ap(), n = b(this.Gv.canvasElement.getContext("2d"));
      n.save();
      const s = this.Li.Ha();
      n.font = this._p(), s.length > 0 && (t = Math.max(this.Fv.xi(n, s[0].so), this.Fv.xi(n, s[s.length - 1].so)));
      const e2 = this.up();
      for (let i2 = e2.length; i2--; ) {
        const s2 = this.Fv.xi(n, e2[i2].Kt());
        s2 > t && (t = s2);
      }
      const r2 = this.Li.Ct();
      if (null !== r2 && null !== this.Ev && (2 !== (h2 = this.cn.crosshair).mode && h2.horzLine.visible && h2.horzLine.labelVisible)) {
        const i2 = this.Li.pn(1, r2), s2 = this.Li.pn(this.Ev.height - 2, r2);
        t = Math.max(t, this.Fv.xi(n, this.Li.Fi(Math.floor(Math.min(i2, s2)) + 0.11111111111111, r2)), this.Fv.xi(n, this.Li.Fi(Math.ceil(Math.max(i2, s2)) - 0.11111111111111, r2)));
      }
      var h2;
      n.restore();
      const l2 = t || 34;
      return rs(Math.ceil(i.C + i.T + i.A + i.I + 5 + l2));
    }
    cp(t) {
      null !== this.Ev && equalSizes(this.Ev, t) || (this.Ev = t, this.jv = true, this.Gv.resizeCanvasElement(t), this.Jv.resizeCanvasElement(t), this.jv = false, this.Kv.style.width = `${t.width}px`, this.Kv.style.height = `${t.height}px`);
    }
    dp() {
      return b(this.Ev).width;
    }
    Gi(t) {
      this.Li !== t && (null !== this.Li && this.Li.Ko().p(this), this.Li = t, t.Ko().l(this.fo.bind(this), this));
    }
    Dt() {
      return this.Li;
    }
    nr() {
      const t = this.tn.fp();
      this.tn.$v().$t().E_(t, b(this.Dt()));
    }
    vp(t) {
      if (null === this.Ev)
        return;
      if (1 !== t) {
        this.pp(), this.Gv.applySuggestedBitmapSize();
        const t2 = tryCreateCanvasRenderingTarget2D(this.Gv);
        null !== t2 && (t2.useBitmapCoordinateSpace((t3) => {
          this.mp(t3), this.Ie(t3);
        }), this.tn.bp(t2, this.Xv), this.wp(t2), this.tn.bp(t2, this.Yv), this.gp(t2));
      }
      this.Jv.applySuggestedBitmapSize();
      const i = tryCreateCanvasRenderingTarget2D(this.Jv);
      null !== i && (i.useBitmapCoordinateSpace(({ context: t2, bitmapSize: i2 }) => {
        t2.clearRect(0, 0, i2.width, i2.height);
      }), this.Mp(i), this.tn.bp(i, this.Zv));
    }
    xp() {
      return this.Gv.bitmapSize;
    }
    Sp(t, i, n) {
      const s = this.xp();
      s.width > 0 && s.height > 0 && t.drawImage(this.Gv.canvasElement, i, n);
    }
    bt() {
      var t;
      null === (t = this.Li) || void 0 === t || t.Ha();
    }
    Qv(t) {
      if (null === this.Li || this.Li.Ni() || !this.cn.handleScale.axisPressedMouseMove.price)
        return;
      const i = this.tn.$v().$t(), n = this.tn.fp();
      this.Nv = true, i.V_(n, this.Li, t.localY);
    }
    tp(t) {
      if (null === this.Li || !this.cn.handleScale.axisPressedMouseMove.price)
        return;
      const i = this.tn.$v().$t(), n = this.tn.fp(), s = this.Li;
      i.O_(n, s, t.localY);
    }
    ip() {
      if (null === this.Li || !this.cn.handleScale.axisPressedMouseMove.price)
        return;
      const t = this.tn.$v().$t(), i = this.tn.fp(), n = this.Li;
      this.Nv && (this.Nv = false, t.B_(i, n));
    }
    np(t) {
      if (null === this.Li || !this.cn.handleScale.axisPressedMouseMove.price)
        return;
      const i = this.tn.$v().$t(), n = this.tn.fp();
      this.Nv = false, i.B_(n, this.Li);
    }
    sp(t) {
      this.cn.handleScale.axisDoubleClickReset.price && this.nr();
    }
    ep(t) {
      if (null === this.Li)
        return;
      !this.tn.$v().$t().W().handleScale.axisPressedMouseMove.price || this.Li.Mh() || this.Li.Oo() || this.kp(1);
    }
    rp(t) {
      this.kp(0);
    }
    up() {
      const t = [], i = null === this.Li ? void 0 : this.Li;
      return ((n) => {
        for (let s = 0; s < n.length; ++s) {
          const e2 = n[s].Rn(this.tn.fp(), i);
          for (let i2 = 0; i2 < e2.length; i2++)
            t.push(e2[i2]);
        }
      })(this.tn.fp().Uo()), t;
    }
    mp({ context: t, bitmapSize: i }) {
      const { width: n, height: s } = i, e2 = this.tn.fp().$t(), r2 = e2.q(), h2 = e2.bd();
      r2 === h2 ? G(t, 0, 0, n, s, r2) : tt(t, 0, 0, n, s, r2, h2);
    }
    Ie({ context: t, bitmapSize: i, horizontalPixelRatio: n }) {
      if (null === this.Ev || null === this.Li || !this.Li.W().borderVisible)
        return;
      t.fillStyle = this.Li.W().borderColor;
      const s = Math.max(1, Math.floor(this.ap().C * n));
      let e2;
      e2 = this.qv ? i.width - s : 0, t.fillRect(e2, 0, s, i.height);
    }
    wp(t) {
      if (null === this.Ev || null === this.Li)
        return;
      const i = this.Li.Ha(), n = this.Li.W(), s = this.ap(), e2 = this.qv ? this.Ev.width - s.T : 0;
      n.borderVisible && n.ticksVisible && t.useBitmapCoordinateSpace(({ context: t2, horizontalPixelRatio: r2, verticalPixelRatio: h2 }) => {
        t2.fillStyle = n.borderColor;
        const l2 = Math.max(1, Math.floor(h2)), a2 = Math.floor(0.5 * h2), o2 = Math.round(s.T * r2);
        t2.beginPath();
        for (const n2 of i)
          t2.rect(Math.floor(e2 * r2), Math.round(n2.Ea * h2) - a2, o2, l2);
        t2.fill();
      }), t.useMediaCoordinateSpace(({ context: t2 }) => {
        var r2;
        t2.font = this._p(), t2.fillStyle = null !== (r2 = n.textColor) && void 0 !== r2 ? r2 : this.ko.textColor, t2.textAlign = this.qv ? "right" : "left", t2.textBaseline = "middle";
        const h2 = this.qv ? Math.round(e2 - s.A) : Math.round(e2 + s.T + s.A), l2 = i.map((i2) => this.Fv.Mi(t2, i2.so));
        for (let n2 = i.length; n2--; ) {
          const s2 = i[n2];
          t2.fillText(s2.so, h2, s2.Ea + l2[n2]);
        }
      });
    }
    pp() {
      if (null === this.Ev || null === this.Li)
        return;
      const t = [], i = this.Li.Uo().slice(), n = this.tn.fp(), s = this.ap();
      this.Li === n.pr() && this.tn.fp().Uo().forEach((t2) => {
        n.vr(t2) && i.push(t2);
      });
      const e2 = this.Li;
      i.forEach((i2) => {
        i2.Rn(n, e2).forEach((i3) => {
          i3.Oi(null), i3.Bi() && t.push(i3);
        });
      }), t.forEach((t2) => t2.Oi(t2.ki()));
      this.Li.W().alignLabels && this.yp(t, s);
    }
    yp(t, i) {
      if (null === this.Ev)
        return;
      const n = this.Ev.height / 2, s = t.filter((t2) => t2.ki() <= n), e2 = t.filter((t2) => t2.ki() > n);
      s.sort((t2, i2) => i2.ki() - t2.ki()), e2.sort((t2, i2) => t2.ki() - i2.ki());
      for (const n2 of t) {
        const t2 = Math.floor(n2.At(i) / 2), s2 = n2.ki();
        s2 > -t2 && s2 < t2 && n2.Oi(t2), s2 > this.Ev.height - t2 && s2 < this.Ev.height + t2 && n2.Oi(this.Ev.height - t2);
      }
      ys(s, 1, this.Ev.height, i), ys(e2, -1, this.Ev.height, i);
    }
    gp(t) {
      if (null === this.Ev)
        return;
      const i = this.up(), n = this.ap(), s = this.qv ? "right" : "left";
      i.forEach((i2) => {
        if (i2.Ai()) {
          i2.gt(b(this.Li)).X(t, n, this.Fv, s);
        }
      });
    }
    Mp(t) {
      if (null === this.Ev || null === this.Li)
        return;
      const i = this.tn.$v().$t(), n = [], s = this.tn.fp(), e2 = i.Zc().Rn(s, this.Li);
      e2.length && n.push(e2);
      const r2 = this.ap(), h2 = this.qv ? "right" : "left";
      n.forEach((i2) => {
        i2.forEach((i3) => {
          i3.gt(b(this.Li)).X(t, r2, this.Fv, h2);
        });
      });
    }
    kp(t) {
      this.Kv.style.cursor = 1 === t ? "ns-resize" : "default";
    }
    fo() {
      const t = this.op();
      this.Wv < t && this.tn.$v().$t().Kl(), this.Wv = t;
    }
    _p() {
      return F(this.ko.fontSize, this.ko.fontFamily);
    }
  };
  function Ts(t, i) {
    var n, s;
    return null !== (s = null === (n = t.ua) || void 0 === n ? void 0 : n.call(t, i)) && void 0 !== s ? s : [];
  }
  function Ps(t, i) {
    var n, s;
    return null !== (s = null === (n = t.Pn) || void 0 === n ? void 0 : n.call(t, i)) && void 0 !== s ? s : [];
  }
  function Rs(t, i) {
    var n, s;
    return null !== (s = null === (n = t.Ji) || void 0 === n ? void 0 : n.call(t, i)) && void 0 !== s ? s : [];
  }
  function Ds(t, i) {
    var n, s;
    return null !== (s = null === (n = t.aa) || void 0 === n ? void 0 : n.call(t, i)) && void 0 !== s ? s : [];
  }
  var Vs = class _Vs {
    constructor(i, n) {
      this.Ev = size({ width: 0, height: 0 }), this.Cp = null, this.Tp = null, this.Pp = null, this.Rp = null, this.Dp = false, this.Vp = new D(), this.Op = new D(), this.Bp = 0, this.Ap = false, this.Ip = null, this.zp = false, this.Lp = null, this.Ep = null, this.jv = false, this.Hv = () => {
        this.jv || null === this.Np || this.$i().Uh();
      }, this.Uv = () => {
        this.jv || null === this.Np || this.$i().Uh();
      }, this.Qd = i, this.Np = n, this.Np.W_().l(this.Fp.bind(this), this, true), this.Wp = document.createElement("td"), this.Wp.style.padding = "0", this.Wp.style.position = "relative";
      const s = document.createElement("div");
      s.style.width = "100%", s.style.height = "100%", s.style.position = "relative", s.style.overflow = "hidden", this.jp = document.createElement("td"), this.jp.style.padding = "0", this.Hp = document.createElement("td"), this.Hp.style.padding = "0", this.Wp.appendChild(s), this.Gv = _s(s, size({ width: 16, height: 16 })), this.Gv.subscribeSuggestedBitmapSizeChanged(this.Hv);
      const e2 = this.Gv.canvasElement;
      e2.style.position = "absolute", e2.style.zIndex = "1", e2.style.left = "0", e2.style.top = "0", this.Jv = _s(s, size({ width: 16, height: 16 })), this.Jv.subscribeSuggestedBitmapSizeChanged(this.Uv);
      const r2 = this.Jv.canvasElement;
      r2.style.position = "absolute", r2.style.zIndex = "2", r2.style.left = "0", r2.style.top = "0", this.$p = document.createElement("tr"), this.$p.appendChild(this.jp), this.$p.appendChild(this.Wp), this.$p.appendChild(this.Hp), this.Up(), this.hp = new ps(this.Jv.canvasElement, this, { ev: () => null === this.Ip && !this.Qd.W().handleScroll.vertTouchDrag, rv: () => null === this.Ip && !this.Qd.W().handleScroll.horzTouchDrag });
    }
    S() {
      null !== this.Cp && this.Cp.S(), null !== this.Tp && this.Tp.S(), this.Pp = null, this.Jv.unsubscribeSuggestedBitmapSizeChanged(this.Uv), us(this.Jv.canvasElement), this.Jv.dispose(), this.Gv.unsubscribeSuggestedBitmapSizeChanged(this.Hv), us(this.Gv.canvasElement), this.Gv.dispose(), null !== this.Np && this.Np.W_().p(this), this.hp.S();
    }
    fp() {
      return b(this.Np);
    }
    qp(t) {
      var i, n;
      null !== this.Np && this.Np.W_().p(this), this.Np = t, null !== this.Np && this.Np.W_().l(_Vs.prototype.Fp.bind(this), this, true), this.Up(), this.Qd.Yp().indexOf(this) === this.Qd.Yp().length - 1 ? (this.Pp = null !== (i = this.Pp) && void 0 !== i ? i : new os(this.Wp, this.Qd), this.Pp.bt()) : (null === (n = this.Pp) || void 0 === n || n.if(), this.Pp = null);
    }
    $v() {
      return this.Qd;
    }
    lp() {
      return this.$p;
    }
    Up() {
      if (null !== this.Np && (this.Zp(), 0 !== this.$i().wt().length)) {
        if (null !== this.Cp) {
          const t = this.Np.R_();
          this.Cp.Gi(b(t));
        }
        if (null !== this.Tp) {
          const t = this.Np.D_();
          this.Tp.Gi(b(t));
        }
      }
    }
    Xp() {
      null !== this.Cp && this.Cp.bt(), null !== this.Tp && this.Tp.bt();
    }
    M_() {
      return null !== this.Np ? this.Np.M_() : 0;
    }
    x_(t) {
      this.Np && this.Np.x_(t);
    }
    Qf(t) {
      if (!this.Np)
        return;
      this.Kp();
      const i = t.localX, n = t.localY;
      this.Gp(i, n, t);
    }
    bv(t) {
      this.Kp(), this.Jp(), this.Gp(t.localX, t.localY, t);
    }
    tv(t) {
      var i;
      if (!this.Np)
        return;
      this.Kp();
      const n = t.localX, s = t.localY;
      this.Gp(n, s, t);
      const e2 = this.wr(n, s);
      this.Qd.Qp(null !== (i = null == e2 ? void 0 : e2.Lv) && void 0 !== i ? i : null), this.$i().jc(e2 && { Hc: e2.Hc, Iv: e2.Iv });
    }
    dv(t) {
      null !== this.Np && (this.Kp(), this.tm(t));
    }
    qf(t) {
      null !== this.Np && this.im(this.Op, t);
    }
    jf(t) {
      this.qf(t);
    }
    av(t) {
      this.Kp(), this.nm(t), this.Gp(t.localX, t.localY, t);
    }
    cv(t) {
      null !== this.Np && (this.Kp(), this.Ap = false, this.sm(t));
    }
    uv(t) {
      null !== this.Np && this.tm(t);
    }
    Rv(t) {
      if (this.Ap = true, null === this.Ip) {
        const i = { x: t.localX, y: t.localY };
        this.rm(i, i, t);
      }
    }
    Pv(t) {
      null !== this.Np && (this.Kp(), this.Np.$t().jc(null), this.hm());
    }
    lm() {
      return this.Vp;
    }
    am() {
      return this.Op;
    }
    xv() {
      this.Bp = 1, this.$i().Un();
    }
    Sv(t, i) {
      if (!this.Qd.W().handleScale.pinch)
        return;
      const n = 5 * (i - this.Bp);
      this.Bp = i, this.$i().Qc(t.nt, n);
    }
    pv(t) {
      this.Ap = false, this.zp = null !== this.Ip, this.Jp();
      const i = this.$i().Zc();
      null !== this.Ip && i.yt() && (this.Lp = { x: i.Yt(), y: i.Zt() }, this.Ip = { x: t.localX, y: t.localY });
    }
    hv(t) {
      if (null === this.Np)
        return;
      const i = t.localX, n = t.localY;
      if (null === this.Ip)
        this.nm(t);
      else {
        this.zp = false;
        const s = b(this.Lp), e2 = s.x + (i - this.Ip.x), r2 = s.y + (n - this.Ip.y);
        this.Gp(e2, r2, t);
      }
    }
    _v(t) {
      0 === this.$v().W().trackingMode.exitMode && (this.zp = true), this.om(), this.sm(t);
    }
    wr(t, i) {
      const n = this.Np;
      return null === n ? null : function(t2, i2, n2) {
        const s = t2.Uo(), e2 = function(t3, i3, n3) {
          var s2, e3;
          let r2, h2;
          for (const o2 of t3) {
            const t4 = null !== (e3 = null === (s2 = o2.va) || void 0 === s2 ? void 0 : s2.call(o2, i3, n3)) && void 0 !== e3 ? e3 : [];
            for (const i4 of t4)
              l2 = i4.zOrder, (!(a2 = null == r2 ? void 0 : r2.zOrder) || "top" === l2 && "top" !== a2 || "normal" === l2 && "bottom" === a2) && (r2 = i4, h2 = o2);
          }
          var l2, a2;
          return r2 && h2 ? { zv: r2, Hc: h2 } : null;
        }(s, i2, n2);
        if ("top" === (null == e2 ? void 0 : e2.zv.zOrder))
          return xs(e2);
        for (const r2 of s) {
          if (e2 && e2.Hc === r2 && "bottom" !== e2.zv.zOrder && !e2.zv.isBackground)
            return xs(e2);
          const s2 = Ss(r2.Pn(t2), i2, n2);
          if (null !== s2)
            return { Hc: r2, Bv: s2.Bv, Iv: s2.Iv };
          if (e2 && e2.Hc === r2 && "bottom" !== e2.zv.zOrder && e2.zv.isBackground)
            return xs(e2);
        }
        return (null == e2 ? void 0 : e2.zv) ? xs(e2) : null;
      }(n, t, i);
    }
    _m(i, n) {
      b("left" === n ? this.Cp : this.Tp).cp(size({ width: i, height: this.Ev.height }));
    }
    um() {
      return this.Ev;
    }
    cp(t) {
      equalSizes(this.Ev, t) || (this.Ev = t, this.jv = true, this.Gv.resizeCanvasElement(t), this.Jv.resizeCanvasElement(t), this.jv = false, this.Wp.style.width = t.width + "px", this.Wp.style.height = t.height + "px");
    }
    dm() {
      const t = b(this.Np);
      t.P_(t.R_()), t.P_(t.D_());
      for (const i of t.Ba())
        if (t.vr(i)) {
          const n = i.Dt();
          null !== n && t.P_(n), i.Vn();
        }
    }
    xp() {
      return this.Gv.bitmapSize;
    }
    Sp(t, i, n) {
      const s = this.xp();
      s.width > 0 && s.height > 0 && t.drawImage(this.Gv.canvasElement, i, n);
    }
    vp(t) {
      if (0 === t)
        return;
      if (null === this.Np)
        return;
      if (t > 1 && this.dm(), null !== this.Cp && this.Cp.vp(t), null !== this.Tp && this.Tp.vp(t), 1 !== t) {
        this.Gv.applySuggestedBitmapSize();
        const t2 = tryCreateCanvasRenderingTarget2D(this.Gv);
        null !== t2 && (t2.useBitmapCoordinateSpace((t3) => {
          this.mp(t3);
        }), this.Np && (this.fm(t2, Ts), this.vm(t2), this.pm(t2), this.fm(t2, Ps), this.fm(t2, Rs)));
      }
      this.Jv.applySuggestedBitmapSize();
      const i = tryCreateCanvasRenderingTarget2D(this.Jv);
      null !== i && (i.useBitmapCoordinateSpace(({ context: t2, bitmapSize: i2 }) => {
        t2.clearRect(0, 0, i2.width, i2.height);
      }), this.bm(i), this.fm(i, Ds));
    }
    wm() {
      return this.Cp;
    }
    gm() {
      return this.Tp;
    }
    bp(t, i) {
      this.fm(t, i);
    }
    Fp() {
      null !== this.Np && this.Np.W_().p(this), this.Np = null;
    }
    tm(t) {
      this.im(this.Vp, t);
    }
    im(t, i) {
      const n = i.localX, s = i.localY;
      t.M() && t.m(this.$i().St().Nu(n), { x: n, y: s }, i);
    }
    mp({ context: t, bitmapSize: i }) {
      const { width: n, height: s } = i, e2 = this.$i(), r2 = e2.q(), h2 = e2.bd();
      r2 === h2 ? G(t, 0, 0, n, s, h2) : tt(t, 0, 0, n, s, r2, h2);
    }
    vm(t) {
      const i = b(this.Np).j_().qh().gt();
      null !== i && i.X(t, false);
    }
    pm(t) {
      const i = this.$i().Yc();
      this.Mm(t, Ps, cs, i), this.Mm(t, Ps, ds, i);
    }
    bm(t) {
      this.Mm(t, Ps, ds, this.$i().Zc());
    }
    fm(t, i) {
      const n = b(this.Np).Uo();
      for (const s of n)
        this.Mm(t, i, cs, s);
      for (const s of n)
        this.Mm(t, i, ds, s);
    }
    Mm(t, i, n, s) {
      const e2 = b(this.Np), r2 = e2.$t().Wc(), h2 = null !== r2 && r2.Hc === s, l2 = null !== r2 && h2 && void 0 !== r2.Iv ? r2.Iv.Mr : void 0;
      fs(i, (i2) => n(i2, t, h2, l2), s, e2);
    }
    Zp() {
      if (null === this.Np)
        return;
      const t = this.Qd, i = this.Np.R_().W().visible, n = this.Np.D_().W().visible;
      i || null === this.Cp || (this.jp.removeChild(this.Cp.lp()), this.Cp.S(), this.Cp = null), n || null === this.Tp || (this.Hp.removeChild(this.Tp.lp()), this.Tp.S(), this.Tp = null);
      const s = t.$t().ud();
      i && null === this.Cp && (this.Cp = new Cs(this, t.W(), s, "left"), this.jp.appendChild(this.Cp.lp())), n && null === this.Tp && (this.Tp = new Cs(this, t.W(), s, "right"), this.Hp.appendChild(this.Tp.lp()));
    }
    xm(t) {
      return t.Dv && this.Ap || null !== this.Ip;
    }
    Sm(t) {
      return Math.max(0, Math.min(t, this.Ev.width - 1));
    }
    km(t) {
      return Math.max(0, Math.min(t, this.Ev.height - 1));
    }
    Gp(t, i, n) {
      this.$i().ld(this.Sm(t), this.km(i), n, b(this.Np));
    }
    hm() {
      this.$i().od();
    }
    om() {
      this.zp && (this.Ip = null, this.hm());
    }
    rm(t, i, n) {
      this.Ip = t, this.zp = false, this.Gp(i.x, i.y, n);
      const s = this.$i().Zc();
      this.Lp = { x: s.Yt(), y: s.Zt() };
    }
    $i() {
      return this.Qd.$t();
    }
    sm(t) {
      if (!this.Dp)
        return;
      const i = this.$i(), n = this.fp();
      if (i.z_(n, n.vn()), this.Rp = null, this.Dp = false, i.ed(), null !== this.Ep) {
        const t2 = performance.now(), n2 = i.St();
        this.Ep.Vr(n2.Hu(), t2), this.Ep.Qu(t2) || i.Zn(this.Ep);
      }
    }
    Kp() {
      this.Ip = null;
    }
    Jp() {
      if (!this.Np)
        return;
      if (this.$i().Un(), document.activeElement !== document.body && document.activeElement !== document.documentElement)
        b(document.activeElement).blur();
      else {
        const t = document.getSelection();
        null !== t && t.removeAllRanges();
      }
      !this.Np.vn().Ni() && this.$i().St().Ni();
    }
    nm(t) {
      if (null === this.Np)
        return;
      const i = this.$i(), n = i.St();
      if (n.Ni())
        return;
      const s = this.Qd.W(), e2 = s.handleScroll, r2 = s.kineticScroll;
      if ((!e2.pressedMouseMove || t.Dv) && (!e2.horzTouchDrag && !e2.vertTouchDrag || !t.Dv))
        return;
      const h2 = this.Np.vn(), l2 = performance.now();
      if (null !== this.Rp || this.xm(t) || (this.Rp = { x: t.clientX, y: t.clientY, Od: l2, ym: t.localX, Cm: t.localY }), null !== this.Rp && !this.Dp && (this.Rp.x !== t.clientX || this.Rp.y !== t.clientY)) {
        if (t.Dv && r2.touch || !t.Dv && r2.mouse) {
          const t2 = n.le();
          this.Ep = new as(0.2 / t2, 7 / t2, 0.997, 15 / t2), this.Ep.Yd(n.Hu(), this.Rp.Od);
        } else
          this.Ep = null;
        h2.Ni() || i.A_(this.Np, h2, t.localY), i.nd(t.localX), this.Dp = true;
      }
      this.Dp && (h2.Ni() || i.I_(this.Np, h2, t.localY), i.sd(t.localX), null !== this.Ep && this.Ep.Yd(n.Hu(), l2));
    }
  };
  var Os = class {
    constructor(i, n, s, e2, r2) {
      this.ft = true, this.Ev = size({ width: 0, height: 0 }), this.Hv = () => this.vp(3), this.qv = "left" === i, this.Oc = s.ud, this.cn = n, this.Tm = e2, this.Pm = r2, this.Kv = document.createElement("div"), this.Kv.style.width = "25px", this.Kv.style.height = "100%", this.Kv.style.overflow = "hidden", this.Gv = _s(this.Kv, size({ width: 16, height: 16 })), this.Gv.subscribeSuggestedBitmapSizeChanged(this.Hv);
    }
    S() {
      this.Gv.unsubscribeSuggestedBitmapSizeChanged(this.Hv), us(this.Gv.canvasElement), this.Gv.dispose();
    }
    lp() {
      return this.Kv;
    }
    um() {
      return this.Ev;
    }
    cp(t) {
      equalSizes(this.Ev, t) || (this.Ev = t, this.Gv.resizeCanvasElement(t), this.Kv.style.width = `${t.width}px`, this.Kv.style.height = `${t.height}px`, this.ft = true);
    }
    vp(t) {
      if (t < 3 && !this.ft)
        return;
      if (0 === this.Ev.width || 0 === this.Ev.height)
        return;
      this.ft = false, this.Gv.applySuggestedBitmapSize();
      const i = tryCreateCanvasRenderingTarget2D(this.Gv);
      null !== i && i.useBitmapCoordinateSpace((t2) => {
        this.mp(t2), this.Ie(t2);
      });
    }
    xp() {
      return this.Gv.bitmapSize;
    }
    Sp(t, i, n) {
      const s = this.xp();
      s.width > 0 && s.height > 0 && t.drawImage(this.Gv.canvasElement, i, n);
    }
    Ie({ context: t, bitmapSize: i, horizontalPixelRatio: n, verticalPixelRatio: s }) {
      if (!this.Tm())
        return;
      t.fillStyle = this.cn.timeScale.borderColor;
      const e2 = Math.floor(this.Oc.W().C * n), r2 = Math.floor(this.Oc.W().C * s), h2 = this.qv ? i.width - e2 : 0;
      t.fillRect(h2, 0, e2, r2);
    }
    mp({ context: t, bitmapSize: i }) {
      G(t, 0, 0, i.width, i.height, this.Pm());
    }
  };
  function Bs(t) {
    return (i) => {
      var n, s;
      return null !== (s = null === (n = i.fa) || void 0 === n ? void 0 : n.call(i, t)) && void 0 !== s ? s : [];
    };
  }
  var As = Bs("normal");
  var Is = Bs("top");
  var zs = Bs("bottom");
  var Ls = class {
    constructor(i, n) {
      this.Rm = null, this.Dm = null, this.k = null, this.Vm = false, this.Ev = size({ width: 0, height: 0 }), this.Om = new D(), this.Fv = new ni(5), this.jv = false, this.Hv = () => {
        this.jv || this.Qd.$t().Uh();
      }, this.Uv = () => {
        this.jv || this.Qd.$t().Uh();
      }, this.Qd = i, this.q_ = n, this.cn = i.W().layout, this.Xd = document.createElement("tr"), this.Bm = document.createElement("td"), this.Bm.style.padding = "0", this.Am = document.createElement("td"), this.Am.style.padding = "0", this.Kv = document.createElement("td"), this.Kv.style.height = "25px", this.Kv.style.padding = "0", this.Im = document.createElement("div"), this.Im.style.width = "100%", this.Im.style.height = "100%", this.Im.style.position = "relative", this.Im.style.overflow = "hidden", this.Kv.appendChild(this.Im), this.Gv = _s(this.Im, size({ width: 16, height: 16 })), this.Gv.subscribeSuggestedBitmapSizeChanged(this.Hv);
      const s = this.Gv.canvasElement;
      s.style.position = "absolute", s.style.zIndex = "1", s.style.left = "0", s.style.top = "0", this.Jv = _s(this.Im, size({ width: 16, height: 16 })), this.Jv.subscribeSuggestedBitmapSizeChanged(this.Uv);
      const e2 = this.Jv.canvasElement;
      e2.style.position = "absolute", e2.style.zIndex = "2", e2.style.left = "0", e2.style.top = "0", this.Xd.appendChild(this.Bm), this.Xd.appendChild(this.Kv), this.Xd.appendChild(this.Am), this.zm(), this.Qd.$t().g_().l(this.zm.bind(this), this), this.hp = new ps(this.Jv.canvasElement, this, { ev: () => true, rv: () => !this.Qd.W().handleScroll.horzTouchDrag });
    }
    S() {
      this.hp.S(), null !== this.Rm && this.Rm.S(), null !== this.Dm && this.Dm.S(), this.Jv.unsubscribeSuggestedBitmapSizeChanged(this.Uv), us(this.Jv.canvasElement), this.Jv.dispose(), this.Gv.unsubscribeSuggestedBitmapSizeChanged(this.Hv), us(this.Gv.canvasElement), this.Gv.dispose();
    }
    lp() {
      return this.Xd;
    }
    Lm() {
      return this.Rm;
    }
    Em() {
      return this.Dm;
    }
    bv(t) {
      if (this.Vm)
        return;
      this.Vm = true;
      const i = this.Qd.$t();
      !i.St().Ni() && this.Qd.W().handleScale.axisPressedMouseMove.time && i.Jc(t.localX);
    }
    pv(t) {
      this.bv(t);
    }
    wv() {
      const t = this.Qd.$t();
      !t.St().Ni() && this.Vm && (this.Vm = false, this.Qd.W().handleScale.axisPressedMouseMove.time && t.hd());
    }
    av(t) {
      const i = this.Qd.$t();
      !i.St().Ni() && this.Qd.W().handleScale.axisPressedMouseMove.time && i.rd(t.localX);
    }
    hv(t) {
      this.av(t);
    }
    cv() {
      this.Vm = false;
      const t = this.Qd.$t();
      t.St().Ni() && !this.Qd.W().handleScale.axisPressedMouseMove.time || t.hd();
    }
    _v() {
      this.cv();
    }
    qf() {
      this.Qd.W().handleScale.axisDoubleClickReset.time && this.Qd.$t().Kn();
    }
    jf() {
      this.qf();
    }
    Qf() {
      this.Qd.$t().W().handleScale.axisPressedMouseMove.time && this.kp(1);
    }
    Pv() {
      this.kp(0);
    }
    um() {
      return this.Ev;
    }
    Nm() {
      return this.Om;
    }
    Fm(i, s, e2) {
      equalSizes(this.Ev, i) || (this.Ev = i, this.jv = true, this.Gv.resizeCanvasElement(i), this.Jv.resizeCanvasElement(i), this.jv = false, this.Kv.style.width = `${i.width}px`, this.Kv.style.height = `${i.height}px`, this.Om.m(i)), null !== this.Rm && this.Rm.cp(size({ width: s, height: i.height })), null !== this.Dm && this.Dm.cp(size({ width: e2, height: i.height }));
    }
    Wm() {
      const t = this.jm();
      return Math.ceil(t.C + t.T + t.P + t.L + t.B + t.Hm);
    }
    bt() {
      this.Qd.$t().St().Ha();
    }
    xp() {
      return this.Gv.bitmapSize;
    }
    Sp(t, i, n) {
      const s = this.xp();
      s.width > 0 && s.height > 0 && t.drawImage(this.Gv.canvasElement, i, n);
    }
    vp(t) {
      if (0 === t)
        return;
      if (1 !== t) {
        this.Gv.applySuggestedBitmapSize();
        const i2 = tryCreateCanvasRenderingTarget2D(this.Gv);
        null !== i2 && (i2.useBitmapCoordinateSpace((t2) => {
          this.mp(t2), this.Ie(t2), this.$m(i2, zs);
        }), this.wp(i2), this.$m(i2, As)), null !== this.Rm && this.Rm.vp(t), null !== this.Dm && this.Dm.vp(t);
      }
      this.Jv.applySuggestedBitmapSize();
      const i = tryCreateCanvasRenderingTarget2D(this.Jv);
      null !== i && (i.useBitmapCoordinateSpace(({ context: t2, bitmapSize: i2 }) => {
        t2.clearRect(0, 0, i2.width, i2.height);
      }), this.Um([...this.Qd.$t().wt(), this.Qd.$t().Zc()], i), this.$m(i, Is));
    }
    $m(t, i) {
      const n = this.Qd.$t().wt();
      for (const s of n)
        fs(i, (i2) => cs(i2, t, false, void 0), s, void 0);
      for (const s of n)
        fs(i, (i2) => ds(i2, t, false, void 0), s, void 0);
    }
    mp({ context: t, bitmapSize: i }) {
      G(t, 0, 0, i.width, i.height, this.Qd.$t().bd());
    }
    Ie({ context: t, bitmapSize: i, verticalPixelRatio: n }) {
      if (this.Qd.W().timeScale.borderVisible) {
        t.fillStyle = this.qm();
        const s = Math.max(1, Math.floor(this.jm().C * n));
        t.fillRect(0, 0, i.width, s);
      }
    }
    wp(t) {
      const i = this.Qd.$t().St(), n = i.Ha();
      if (!n || 0 === n.length)
        return;
      const s = this.q_.maxTickMarkWeight(n), e2 = this.jm(), r2 = i.W();
      r2.borderVisible && r2.ticksVisible && t.useBitmapCoordinateSpace(({ context: t2, horizontalPixelRatio: i2, verticalPixelRatio: s2 }) => {
        t2.strokeStyle = this.qm(), t2.fillStyle = this.qm();
        const r3 = Math.max(1, Math.floor(i2)), h2 = Math.floor(0.5 * i2);
        t2.beginPath();
        const l2 = Math.round(e2.T * s2);
        for (let s3 = n.length; s3--; ) {
          const e3 = Math.round(n[s3].coord * i2);
          t2.rect(e3 - h2, 0, r3, l2);
        }
        t2.fill();
      }), t.useMediaCoordinateSpace(({ context: t2 }) => {
        const i2 = e2.C + e2.T + e2.L + e2.P / 2;
        t2.textAlign = "center", t2.textBaseline = "middle", t2.fillStyle = this.$(), t2.font = this._p();
        for (const e3 of n)
          if (e3.weight < s) {
            const n2 = e3.needAlignCoordinate ? this.Ym(t2, e3.coord, e3.label) : e3.coord;
            t2.fillText(e3.label, n2, i2);
          }
        this.Qd.W().timeScale.allowBoldLabels && (t2.font = this.Zm());
        for (const e3 of n)
          if (e3.weight >= s) {
            const n2 = e3.needAlignCoordinate ? this.Ym(t2, e3.coord, e3.label) : e3.coord;
            t2.fillText(e3.label, n2, i2);
          }
      });
    }
    Ym(t, i, n) {
      const s = this.Fv.xi(t, n), e2 = s / 2, r2 = Math.floor(i - e2) + 0.5;
      return r2 < 0 ? i += Math.abs(0 - r2) : r2 + s > this.Ev.width && (i -= Math.abs(this.Ev.width - (r2 + s))), i;
    }
    Um(t, i) {
      const n = this.jm();
      for (const s of t)
        for (const t2 of s.Qi())
          t2.gt().X(i, n);
    }
    qm() {
      return this.Qd.W().timeScale.borderColor;
    }
    $() {
      return this.cn.textColor;
    }
    j() {
      return this.cn.fontSize;
    }
    _p() {
      return F(this.j(), this.cn.fontFamily);
    }
    Zm() {
      return F(this.j(), this.cn.fontFamily, "bold");
    }
    jm() {
      null === this.k && (this.k = { C: 1, N: NaN, L: NaN, B: NaN, ji: NaN, T: 5, P: NaN, R: "", Wi: new ni(), Hm: 0 });
      const t = this.k, i = this._p();
      if (t.R !== i) {
        const n = this.j();
        t.P = n, t.R = i, t.L = 3 * n / 12, t.B = 3 * n / 12, t.ji = 9 * n / 12, t.N = 0, t.Hm = 4 * n / 12, t.Wi.nr();
      }
      return this.k;
    }
    kp(t) {
      this.Kv.style.cursor = 1 === t ? "ew-resize" : "default";
    }
    zm() {
      const t = this.Qd.$t(), i = t.W();
      i.leftPriceScale.visible || null === this.Rm || (this.Bm.removeChild(this.Rm.lp()), this.Rm.S(), this.Rm = null), i.rightPriceScale.visible || null === this.Dm || (this.Am.removeChild(this.Dm.lp()), this.Dm.S(), this.Dm = null);
      const n = { ud: this.Qd.$t().ud() }, s = () => i.leftPriceScale.borderVisible && t.St().W().borderVisible, e2 = () => t.bd();
      i.leftPriceScale.visible && null === this.Rm && (this.Rm = new Os("left", i, n, s, e2), this.Bm.appendChild(this.Rm.lp())), i.rightPriceScale.visible && null === this.Dm && (this.Dm = new Os("right", i, n, s, e2), this.Am.appendChild(this.Dm.lp()));
    }
  };
  var Es = !!ns && !!navigator.userAgentData && navigator.userAgentData.brands.some((t) => t.brand.includes("Chromium")) && !!ns && ((null === (Ns = null === navigator || void 0 === navigator ? void 0 : navigator.userAgentData) || void 0 === Ns ? void 0 : Ns.platform) ? "Windows" === navigator.userAgentData.platform : navigator.userAgent.toLowerCase().indexOf("win") >= 0);
  var Ns;
  var Fs = class {
    constructor(t, i, n) {
      var s;
      this.Xm = [], this.Km = 0, this.ho = 0, this.__ = 0, this.Gm = 0, this.Jm = 0, this.Qm = null, this.tb = false, this.Vp = new D(), this.Op = new D(), this.Rc = new D(), this.ib = null, this.nb = null, this.Jd = t, this.cn = i, this.q_ = n, this.Xd = document.createElement("div"), this.Xd.classList.add("tv-lightweight-charts"), this.Xd.style.overflow = "hidden", this.Xd.style.direction = "ltr", this.Xd.style.width = "100%", this.Xd.style.height = "100%", (s = this.Xd).style.userSelect = "none", s.style.webkitUserSelect = "none", s.style.msUserSelect = "none", s.style.MozUserSelect = "none", s.style.webkitTapHighlightColor = "transparent", this.sb = document.createElement("table"), this.sb.setAttribute("cellspacing", "0"), this.Xd.appendChild(this.sb), this.eb = this.rb.bind(this), Ws(this.cn) && this.hb(true), this.$i = new Ln(this.Vc.bind(this), this.cn, n), this.$t().Xc().l(this.lb.bind(this), this), this.ab = new Ls(this, this.q_), this.sb.appendChild(this.ab.lp());
      const e2 = i.autoSize && this.ob();
      let r2 = this.cn.width, h2 = this.cn.height;
      if (e2 || 0 === r2 || 0 === h2) {
        const i2 = t.getBoundingClientRect();
        r2 = r2 || i2.width, h2 = h2 || i2.height;
      }
      this._b(r2, h2), this.ub(), t.appendChild(this.Xd), this.cb(), this.$i.St().ec().l(this.$i.Kl.bind(this.$i), this), this.$i.g_().l(this.$i.Kl.bind(this.$i), this);
    }
    $t() {
      return this.$i;
    }
    W() {
      return this.cn;
    }
    Yp() {
      return this.Xm;
    }
    fb() {
      return this.ab;
    }
    S() {
      this.hb(false), 0 !== this.Km && window.cancelAnimationFrame(this.Km), this.$i.Xc().p(this), this.$i.St().ec().p(this), this.$i.g_().p(this), this.$i.S();
      for (const t of this.Xm)
        this.sb.removeChild(t.lp()), t.lm().p(this), t.am().p(this), t.S();
      this.Xm = [], b(this.ab).S(), null !== this.Xd.parentElement && this.Xd.parentElement.removeChild(this.Xd), this.Rc.S(), this.Vp.S(), this.Op.S(), this.pb();
    }
    _b(i, n, s = false) {
      if (this.ho === n && this.__ === i)
        return;
      const e2 = function(i2) {
        const n2 = Math.floor(i2.width), s2 = Math.floor(i2.height);
        return size({ width: n2 - n2 % 2, height: s2 - s2 % 2 });
      }(size({ width: i, height: n }));
      this.ho = e2.height, this.__ = e2.width;
      const r2 = this.ho + "px", h2 = this.__ + "px";
      b(this.Xd).style.height = r2, b(this.Xd).style.width = h2, this.sb.style.height = r2, this.sb.style.width = h2, s ? this.mb(ut.es(), performance.now()) : this.$i.Kl();
    }
    vp(t) {
      void 0 === t && (t = ut.es());
      for (let i = 0; i < this.Xm.length; i++)
        this.Xm[i].vp(t.Hn(i).Fn);
      this.cn.timeScale.visible && this.ab.vp(t.jn());
    }
    $h(t) {
      const i = Ws(this.cn);
      this.$i.$h(t);
      const n = Ws(this.cn);
      n !== i && this.hb(n), this.cb(), this.bb(t);
    }
    lm() {
      return this.Vp;
    }
    am() {
      return this.Op;
    }
    Xc() {
      return this.Rc;
    }
    wb() {
      null !== this.Qm && (this.mb(this.Qm, performance.now()), this.Qm = null);
      const t = this.gb(null), i = document.createElement("canvas");
      i.width = t.width, i.height = t.height;
      const n = b(i.getContext("2d"));
      return this.gb(n), i;
    }
    Mb(t) {
      if ("left" === t && !this.xb())
        return 0;
      if ("right" === t && !this.Sb())
        return 0;
      if (0 === this.Xm.length)
        return 0;
      return b("left" === t ? this.Xm[0].wm() : this.Xm[0].gm()).dp();
    }
    kb() {
      return this.cn.autoSize && null !== this.ib;
    }
    yb() {
      return this.Xd;
    }
    Qp(t) {
      this.nb = t, this.nb ? this.yb().style.setProperty("cursor", t) : this.yb().style.removeProperty("cursor");
    }
    Cb() {
      return this.nb;
    }
    Tb() {
      return m(this.Xm[0]).um();
    }
    bb(t) {
      (void 0 !== t.autoSize || !this.ib || void 0 === t.width && void 0 === t.height) && (t.autoSize && !this.ib && this.ob(), false === t.autoSize && null !== this.ib && this.pb(), t.autoSize || void 0 === t.width && void 0 === t.height || this._b(t.width || this.__, t.height || this.ho));
    }
    gb(i) {
      let n = 0, s = 0;
      const e2 = this.Xm[0], r2 = (t, n2) => {
        let s2 = 0;
        for (let e3 = 0; e3 < this.Xm.length; e3++) {
          const r3 = this.Xm[e3], h3 = b("left" === t ? r3.wm() : r3.gm()), l2 = h3.xp();
          null !== i && h3.Sp(i, n2, s2), s2 += l2.height;
        }
      };
      if (this.xb()) {
        r2("left", 0);
        n += b(e2.wm()).xp().width;
      }
      for (let t = 0; t < this.Xm.length; t++) {
        const e3 = this.Xm[t], r3 = e3.xp();
        null !== i && e3.Sp(i, n, s), s += r3.height;
      }
      if (n += e2.xp().width, this.Sb()) {
        r2("right", n);
        n += b(e2.gm()).xp().width;
      }
      const h2 = (t, n2, s2) => {
        b("left" === t ? this.ab.Lm() : this.ab.Em()).Sp(b(i), n2, s2);
      };
      if (this.cn.timeScale.visible) {
        const t = this.ab.xp();
        if (null !== i) {
          let n2 = 0;
          this.xb() && (h2("left", n2, s), n2 = b(e2.wm()).xp().width), this.ab.Sp(i, n2, s), n2 += t.width, this.Sb() && h2("right", n2, s);
        }
        s += t.height;
      }
      return size({ width: n, height: s });
    }
    Pb() {
      let i = 0, n = 0, s = 0;
      for (const t of this.Xm)
        this.xb() && (n = Math.max(n, b(t.wm()).op(), this.cn.leftPriceScale.minimumWidth)), this.Sb() && (s = Math.max(s, b(t.gm()).op(), this.cn.rightPriceScale.minimumWidth)), i += t.M_();
      n = rs(n), s = rs(s);
      const e2 = this.__, r2 = this.ho, h2 = Math.max(e2 - n - s, 0), l2 = this.cn.timeScale.visible;
      let a2 = l2 ? Math.max(this.ab.Wm(), this.cn.timeScale.minimumHeight) : 0;
      var o2;
      a2 = (o2 = a2) + o2 % 2;
      const _2 = 0 + a2, u2 = r2 < _2 ? 0 : r2 - _2, c2 = u2 / i;
      let d2 = 0;
      for (let i2 = 0; i2 < this.Xm.length; ++i2) {
        const e3 = this.Xm[i2];
        e3.qp(this.$i.qc()[i2]);
        let r3 = 0, l3 = 0;
        l3 = i2 === this.Xm.length - 1 ? u2 - d2 : Math.round(e3.M_() * c2), r3 = Math.max(l3, 2), d2 += r3, e3.cp(size({ width: h2, height: r3 })), this.xb() && e3._m(n, "left"), this.Sb() && e3._m(s, "right"), e3.fp() && this.$i.Kc(e3.fp(), r3);
      }
      this.ab.Fm(size({ width: l2 ? h2 : 0, height: a2 }), l2 ? n : 0, l2 ? s : 0), this.$i.S_(h2), this.Gm !== n && (this.Gm = n), this.Jm !== s && (this.Jm = s);
    }
    hb(t) {
      t ? this.Xd.addEventListener("wheel", this.eb, { passive: false }) : this.Xd.removeEventListener("wheel", this.eb);
    }
    Rb(t) {
      switch (t.deltaMode) {
        case t.DOM_DELTA_PAGE:
          return 120;
        case t.DOM_DELTA_LINE:
          return 32;
      }
      return Es ? 1 / window.devicePixelRatio : 1;
    }
    rb(t) {
      if (!(0 !== t.deltaX && this.cn.handleScroll.mouseWheel || 0 !== t.deltaY && this.cn.handleScale.mouseWheel))
        return;
      const i = this.Rb(t), n = i * t.deltaX / 100, s = -i * t.deltaY / 100;
      if (t.cancelable && t.preventDefault(), 0 !== s && this.cn.handleScale.mouseWheel) {
        const i2 = Math.sign(s) * Math.min(1, Math.abs(s)), n2 = t.clientX - this.Xd.getBoundingClientRect().left;
        this.$t().Qc(n2, i2);
      }
      0 !== n && this.cn.handleScroll.mouseWheel && this.$t().td(-80 * n);
    }
    mb(t, i) {
      var n;
      const s = t.jn();
      3 === s && this.Db(), 3 !== s && 2 !== s || (this.Vb(t), this.Ob(t, i), this.ab.bt(), this.Xm.forEach((t2) => {
        t2.Xp();
      }), 3 === (null === (n = this.Qm) || void 0 === n ? void 0 : n.jn()) && (this.Qm.ts(t), this.Db(), this.Vb(this.Qm), this.Ob(this.Qm, i), t = this.Qm, this.Qm = null)), this.vp(t);
    }
    Ob(t, i) {
      for (const n of t.Qn())
        this.ns(n, i);
    }
    Vb(t) {
      const i = this.$i.qc();
      for (let n = 0; n < i.length; n++)
        t.Hn(n).Wn && i[n].N_();
    }
    ns(t, i) {
      const n = this.$i.St();
      switch (t.qn) {
        case 0:
          n.hc();
          break;
        case 1:
          n.lc(t.Vt);
          break;
        case 2:
          n.Gn(t.Vt);
          break;
        case 3:
          n.Jn(t.Vt);
          break;
        case 4:
          n.qu();
          break;
        case 5:
          t.Vt.Qu(i) || n.Jn(t.Vt.tc(i));
      }
    }
    Vc(t) {
      null !== this.Qm ? this.Qm.ts(t) : this.Qm = t, this.tb || (this.tb = true, this.Km = window.requestAnimationFrame((t2) => {
        if (this.tb = false, this.Km = 0, null !== this.Qm) {
          const i = this.Qm;
          this.Qm = null, this.mb(i, t2);
          for (const n of i.Qn())
            if (5 === n.qn && !n.Vt.Qu(t2)) {
              this.$t().Zn(n.Vt);
              break;
            }
        }
      }));
    }
    Db() {
      this.ub();
    }
    ub() {
      const t = this.$i.qc(), i = t.length, n = this.Xm.length;
      for (let t2 = i; t2 < n; t2++) {
        const t3 = m(this.Xm.pop());
        this.sb.removeChild(t3.lp()), t3.lm().p(this), t3.am().p(this), t3.S();
      }
      for (let s = n; s < i; s++) {
        const i2 = new Vs(this, t[s]);
        i2.lm().l(this.Bb.bind(this), this), i2.am().l(this.Ab.bind(this), this), this.Xm.push(i2), this.sb.insertBefore(i2.lp(), this.ab.lp());
      }
      for (let n2 = 0; n2 < i; n2++) {
        const i2 = t[n2], s = this.Xm[n2];
        s.fp() !== i2 ? s.qp(i2) : s.Up();
      }
      this.cb(), this.Pb();
    }
    Ib(t, i, n) {
      var s;
      const e2 = /* @__PURE__ */ new Map();
      if (null !== t) {
        this.$i.wt().forEach((i2) => {
          const n2 = i2.In().ll(t);
          null !== n2 && e2.set(i2, n2);
        });
      }
      let r2;
      if (null !== t) {
        const i2 = null === (s = this.$i.St().Ui(t)) || void 0 === s ? void 0 : s.originalTime;
        void 0 !== i2 && (r2 = i2);
      }
      const h2 = this.$t().Wc(), l2 = null !== h2 && h2.Hc instanceof Gi ? h2.Hc : void 0, a2 = null !== h2 && void 0 !== h2.Iv ? h2.Iv.gr : void 0;
      return { zb: r2, ee: null != t ? t : void 0, Lb: null != i ? i : void 0, Eb: l2, Nb: e2, Fb: a2, Wb: null != n ? n : void 0 };
    }
    Bb(t, i, n) {
      this.Vp.m(() => this.Ib(t, i, n));
    }
    Ab(t, i, n) {
      this.Op.m(() => this.Ib(t, i, n));
    }
    lb(t, i, n) {
      this.Rc.m(() => this.Ib(t, i, n));
    }
    cb() {
      const t = this.cn.timeScale.visible ? "" : "none";
      this.ab.lp().style.display = t;
    }
    xb() {
      return this.Xm[0].fp().R_().W().visible;
    }
    Sb() {
      return this.Xm[0].fp().D_().W().visible;
    }
    ob() {
      return "ResizeObserver" in window && (this.ib = new ResizeObserver((t) => {
        const i = t.find((t2) => t2.target === this.Jd);
        i && this._b(i.contentRect.width, i.contentRect.height);
      }), this.ib.observe(this.Jd, { box: "border-box" }), true);
    }
    pb() {
      null !== this.ib && this.ib.disconnect(), this.ib = null;
    }
  };
  function Ws(t) {
    return Boolean(t.handleScroll.mouseWheel || t.handleScale.mouseWheel);
  }
  function js(t) {
    return function(t2) {
      return void 0 !== t2.open;
    }(t) || function(t2) {
      return void 0 !== t2.value;
    }(t);
  }
  function Hs(t, i) {
    var n = {};
    for (var s in t)
      Object.prototype.hasOwnProperty.call(t, s) && i.indexOf(s) < 0 && (n[s] = t[s]);
    if (null != t && "function" == typeof Object.getOwnPropertySymbols) {
      var e2 = 0;
      for (s = Object.getOwnPropertySymbols(t); e2 < s.length; e2++)
        i.indexOf(s[e2]) < 0 && Object.prototype.propertyIsEnumerable.call(t, s[e2]) && (n[s[e2]] = t[s[e2]]);
    }
    return n;
  }
  function $s(t, i, n, s) {
    const e2 = n.value, r2 = { ee: i, ot: t, Vt: [e2, e2, e2, e2], zb: s };
    return void 0 !== n.color && (r2.V = n.color), r2;
  }
  function Us(t, i, n, s) {
    const e2 = n.value, r2 = { ee: i, ot: t, Vt: [e2, e2, e2, e2], zb: s };
    return void 0 !== n.lineColor && (r2.lt = n.lineColor), void 0 !== n.topColor && (r2.Ps = n.topColor), void 0 !== n.bottomColor && (r2.Rs = n.bottomColor), r2;
  }
  function qs(t, i, n, s) {
    const e2 = n.value, r2 = { ee: i, ot: t, Vt: [e2, e2, e2, e2], zb: s };
    return void 0 !== n.topLineColor && (r2.Re = n.topLineColor), void 0 !== n.bottomLineColor && (r2.De = n.bottomLineColor), void 0 !== n.topFillColor1 && (r2.ke = n.topFillColor1), void 0 !== n.topFillColor2 && (r2.ye = n.topFillColor2), void 0 !== n.bottomFillColor1 && (r2.Ce = n.bottomFillColor1), void 0 !== n.bottomFillColor2 && (r2.Te = n.bottomFillColor2), r2;
  }
  function Ys(t, i, n, s) {
    const e2 = { ee: i, ot: t, Vt: [n.open, n.high, n.low, n.close], zb: s };
    return void 0 !== n.color && (e2.V = n.color), e2;
  }
  function Zs(t, i, n, s) {
    const e2 = { ee: i, ot: t, Vt: [n.open, n.high, n.low, n.close], zb: s };
    return void 0 !== n.color && (e2.V = n.color), void 0 !== n.borderColor && (e2.Ot = n.borderColor), void 0 !== n.wickColor && (e2.Xh = n.wickColor), e2;
  }
  function Xs(t, i, n, s, e2) {
    const r2 = m(e2)(n), h2 = Math.max(...r2), l2 = Math.min(...r2), a2 = r2[r2.length - 1], o2 = [a2, h2, l2, a2], _2 = n, { time: u2, color: c2 } = _2;
    return { ee: i, ot: t, Vt: o2, zb: s, $e: Hs(_2, ["time", "color"]), V: c2 };
  }
  function Ks(t) {
    return void 0 !== t.Vt;
  }
  function Gs(t, i) {
    return void 0 !== i.customValues && (t.jb = i.customValues), t;
  }
  function Js(t) {
    return (i, n, s, e2, r2, h2) => function(t2, i2) {
      return i2 ? i2(t2) : void 0 === (n2 = t2).open && void 0 === n2.value;
      var n2;
    }(s, h2) ? Gs({ ot: i, ee: n, zb: e2 }, s) : Gs(t(i, n, s, e2, r2), s);
  }
  function Qs(t) {
    return { Candlestick: Js(Zs), Bar: Js(Ys), Area: Js(Us), Baseline: Js(qs), Histogram: Js($s), Line: Js($s), Custom: Js(Xs) }[t];
  }
  function te(t) {
    return { ee: 0, Hb: /* @__PURE__ */ new Map(), la: t };
  }
  function ie(t, i) {
    if (void 0 !== t && 0 !== t.length)
      return { $b: i.key(t[0].ot), Ub: i.key(t[t.length - 1].ot) };
  }
  function ne(t) {
    let i;
    return t.forEach((t2) => {
      void 0 === i && (i = t2.zb);
    }), m(i);
  }
  var se = class {
    constructor(t) {
      this.qb = /* @__PURE__ */ new Map(), this.Yb = /* @__PURE__ */ new Map(), this.Zb = /* @__PURE__ */ new Map(), this.Xb = [], this.q_ = t;
    }
    S() {
      this.qb.clear(), this.Yb.clear(), this.Zb.clear(), this.Xb = [];
    }
    Kb(t, i) {
      let n = 0 !== this.qb.size, s = false;
      const e2 = this.Yb.get(t);
      if (void 0 !== e2)
        if (1 === this.Yb.size)
          n = false, s = true, this.qb.clear();
        else
          for (const i2 of this.Xb)
            i2.pointData.Hb.delete(t) && (s = true);
      let r2 = [];
      if (0 !== i.length) {
        const n2 = i.map((t2) => t2.time), e3 = this.q_.createConverterToInternalObj(i), h3 = Qs(t.Qh()), l2 = t.Ca(), a2 = t.Ta();
        r2 = i.map((i2, r3) => {
          const o2 = e3(i2.time), _2 = this.q_.key(o2);
          let u2 = this.qb.get(_2);
          void 0 === u2 && (u2 = te(o2), this.qb.set(_2, u2), s = true);
          const c2 = h3(o2, u2.ee, i2, n2[r3], l2, a2);
          return u2.Hb.set(t, c2), c2;
        });
      }
      n && this.Gb(), this.Jb(t, r2);
      let h2 = -1;
      if (s) {
        const t2 = [];
        this.qb.forEach((i2) => {
          t2.push({ timeWeight: 0, time: i2.la, pointData: i2, originalTime: ne(i2.Hb) });
        }), t2.sort((t3, i2) => this.q_.key(t3.time) - this.q_.key(i2.time)), h2 = this.Qb(t2);
      }
      return this.tw(t, h2, function(t2, i2, n2) {
        const s2 = ie(t2, n2), e3 = ie(i2, n2);
        if (void 0 !== s2 && void 0 !== e3)
          return { ta: s2.Ub >= e3.Ub && s2.$b >= e3.$b };
      }(this.Yb.get(t), e2, this.q_));
    }
    vd(t) {
      return this.Kb(t, []);
    }
    iw(t, i) {
      const n = i;
      !function(t2) {
        void 0 === t2.zb && (t2.zb = t2.time);
      }(n), this.q_.preprocessData(i);
      const s = this.q_.createConverterToInternalObj([i])(i.time), e2 = this.Zb.get(t);
      if (void 0 !== e2 && this.q_.key(s) < this.q_.key(e2))
        throw new Error(`Cannot update oldest data, last time=${e2}, new time=${s}`);
      let r2 = this.qb.get(this.q_.key(s));
      const h2 = void 0 === r2;
      void 0 === r2 && (r2 = te(s), this.qb.set(this.q_.key(s), r2));
      const l2 = Qs(t.Qh()), a2 = t.Ca(), o2 = t.Ta(), _2 = l2(s, r2.ee, i, n.zb, a2, o2);
      r2.Hb.set(t, _2), this.nw(t, _2);
      const u2 = { ta: Ks(_2) };
      if (!h2)
        return this.tw(t, -1, u2);
      const c2 = { timeWeight: 0, time: r2.la, pointData: r2, originalTime: ne(r2.Hb) }, d2 = Bt(this.Xb, this.q_.key(c2.time), (t2, i2) => this.q_.key(t2.time) < i2);
      this.Xb.splice(d2, 0, c2);
      for (let t2 = d2; t2 < this.Xb.length; ++t2)
        ee(this.Xb[t2].pointData, t2);
      return this.q_.fillWeightsForPoints(this.Xb, d2), this.tw(t, d2, u2);
    }
    nw(t, i) {
      let n = this.Yb.get(t);
      void 0 === n && (n = [], this.Yb.set(t, n));
      const s = 0 !== n.length ? n[n.length - 1] : null;
      null === s || this.q_.key(i.ot) > this.q_.key(s.ot) ? Ks(i) && n.push(i) : Ks(i) ? n[n.length - 1] = i : n.splice(-1, 1), this.Zb.set(t, i.ot);
    }
    Jb(t, i) {
      0 !== i.length ? (this.Yb.set(t, i.filter(Ks)), this.Zb.set(t, i[i.length - 1].ot)) : (this.Yb.delete(t), this.Zb.delete(t));
    }
    Gb() {
      for (const t of this.Xb)
        0 === t.pointData.Hb.size && this.qb.delete(this.q_.key(t.time));
    }
    Qb(t) {
      let i = -1;
      for (let n = 0; n < this.Xb.length && n < t.length; ++n) {
        const s = this.Xb[n], e2 = t[n];
        if (this.q_.key(s.time) !== this.q_.key(e2.time)) {
          i = n;
          break;
        }
        e2.timeWeight = s.timeWeight, ee(e2.pointData, n);
      }
      if (-1 === i && this.Xb.length !== t.length && (i = Math.min(this.Xb.length, t.length)), -1 === i)
        return -1;
      for (let n = i; n < t.length; ++n)
        ee(t[n].pointData, n);
      return this.q_.fillWeightsForPoints(t, i), this.Xb = t, i;
    }
    sw() {
      if (0 === this.Yb.size)
        return null;
      let t = 0;
      return this.Yb.forEach((i) => {
        0 !== i.length && (t = Math.max(t, i[i.length - 1].ee));
      }), t;
    }
    tw(t, i, n) {
      const s = { ew: /* @__PURE__ */ new Map(), St: { Eu: this.sw() } };
      if (-1 !== i)
        this.Yb.forEach((i2, e2) => {
          s.ew.set(e2, { $e: i2, rw: e2 === t ? n : void 0 });
        }), this.Yb.has(t) || s.ew.set(t, { $e: [], rw: n }), s.St.hw = this.Xb, s.St.lw = i;
      else {
        const i2 = this.Yb.get(t);
        s.ew.set(t, { $e: i2 || [], rw: n });
      }
      return s;
    }
  };
  function ee(t, i) {
    t.ee = i, t.Hb.forEach((t2) => {
      t2.ee = i;
    });
  }
  function re(t) {
    const i = { value: t.Vt[3], time: t.zb };
    return void 0 !== t.jb && (i.customValues = t.jb), i;
  }
  function he(t) {
    const i = re(t);
    return void 0 !== t.V && (i.color = t.V), i;
  }
  function le(t) {
    const i = re(t);
    return void 0 !== t.lt && (i.lineColor = t.lt), void 0 !== t.Ps && (i.topColor = t.Ps), void 0 !== t.Rs && (i.bottomColor = t.Rs), i;
  }
  function ae(t) {
    const i = re(t);
    return void 0 !== t.Re && (i.topLineColor = t.Re), void 0 !== t.De && (i.bottomLineColor = t.De), void 0 !== t.ke && (i.topFillColor1 = t.ke), void 0 !== t.ye && (i.topFillColor2 = t.ye), void 0 !== t.Ce && (i.bottomFillColor1 = t.Ce), void 0 !== t.Te && (i.bottomFillColor2 = t.Te), i;
  }
  function oe(t) {
    const i = { open: t.Vt[0], high: t.Vt[1], low: t.Vt[2], close: t.Vt[3], time: t.zb };
    return void 0 !== t.jb && (i.customValues = t.jb), i;
  }
  function _e(t) {
    const i = oe(t);
    return void 0 !== t.V && (i.color = t.V), i;
  }
  function ue(t) {
    const i = oe(t), { V: n, Ot: s, Xh: e2 } = t;
    return void 0 !== n && (i.color = n), void 0 !== s && (i.borderColor = s), void 0 !== e2 && (i.wickColor = e2), i;
  }
  function ce(t) {
    return { Area: le, Line: he, Baseline: ae, Histogram: he, Bar: _e, Candlestick: ue, Custom: de }[t];
  }
  function de(t) {
    const i = t.zb;
    return Object.assign(Object.assign({}, t.$e), { time: i });
  }
  var fe = { vertLine: { color: "#9598A1", width: 1, style: 3, visible: true, labelVisible: true, labelBackgroundColor: "#131722" }, horzLine: { color: "#9598A1", width: 1, style: 3, visible: true, labelVisible: true, labelBackgroundColor: "#131722" }, mode: 1 };
  var ve = { vertLines: { color: "#D6DCDE", style: 0, visible: true }, horzLines: { color: "#D6DCDE", style: 0, visible: true } };
  var pe = { background: { type: "solid", color: "#FFFFFF" }, textColor: "#191919", fontSize: 12, fontFamily: N, attributionLogo: true };
  var me = { autoScale: true, mode: 0, invertScale: false, alignLabels: true, borderVisible: true, borderColor: "#2B2B43", entireTextOnly: false, visible: false, ticksVisible: false, scaleMargins: { bottom: 0.1, top: 0.2 }, minimumWidth: 0 };
  var be = { rightOffset: 0, barSpacing: 6, minBarSpacing: 0.5, fixLeftEdge: false, fixRightEdge: false, lockVisibleTimeRangeOnResize: false, rightBarStaysOnScroll: false, borderVisible: true, borderColor: "#2B2B43", visible: true, timeVisible: false, secondsVisible: true, shiftVisibleRangeOnNewBar: true, allowShiftVisibleRangeOnWhitespaceReplacement: false, ticksVisible: false, uniformDistribution: false, minimumHeight: 0, allowBoldLabels: true };
  var we = { color: "rgba(0, 0, 0, 0)", visible: false, fontSize: 48, fontFamily: N, fontStyle: "", text: "", horzAlign: "center", vertAlign: "center" };
  function ge() {
    return { width: 0, height: 0, autoSize: false, layout: pe, crosshair: fe, grid: ve, overlayPriceScales: Object.assign({}, me), leftPriceScale: Object.assign(Object.assign({}, me), { visible: false }), rightPriceScale: Object.assign(Object.assign({}, me), { visible: true }), timeScale: be, watermark: we, localization: { locale: ns ? navigator.language : "", dateFormat: "dd MMM 'yy" }, handleScroll: { mouseWheel: true, pressedMouseMove: true, horzTouchDrag: true, vertTouchDrag: true }, handleScale: { axisPressedMouseMove: { time: true, price: true }, axisDoubleClickReset: { time: true, price: true }, mouseWheel: true, pinch: true }, kineticScroll: { mouse: false, touch: true }, trackingMode: { exitMode: 1 } };
  }
  var Me = class {
    constructor(t, i) {
      this.aw = t, this.ow = i;
    }
    applyOptions(t) {
      this.aw.$t().$c(this.ow, t);
    }
    options() {
      return this.Li().W();
    }
    width() {
      return _t(this.ow) ? this.aw.Mb(this.ow) : 0;
    }
    Li() {
      return b(this.aw.$t().Uc(this.ow)).Dt;
    }
  };
  function xe(t, i, n) {
    const s = Hs(t, ["time", "originalTime"]), e2 = Object.assign({ time: i }, s);
    return void 0 !== n && (e2.originalTime = n), e2;
  }
  var Se = { color: "#FF0000", price: 0, lineStyle: 2, lineWidth: 1, lineVisible: true, axisLabelVisible: true, title: "", axisLabelColor: "", axisLabelTextColor: "" };
  var ke = class {
    constructor(t) {
      this.Nh = t;
    }
    applyOptions(t) {
      this.Nh.$h(t);
    }
    options() {
      return this.Nh.W();
    }
    _w() {
      return this.Nh;
    }
  };
  var ye = class {
    constructor(t, i, n, s, e2) {
      this.uw = new D(), this.Es = t, this.cw = i, this.dw = n, this.q_ = e2, this.fw = s;
    }
    S() {
      this.uw.S();
    }
    priceFormatter() {
      return this.Es.ba();
    }
    priceToCoordinate(t) {
      const i = this.Es.Ct();
      return null === i ? null : this.Es.Dt().Rt(t, i.Vt);
    }
    coordinateToPrice(t) {
      const i = this.Es.Ct();
      return null === i ? null : this.Es.Dt().pn(t, i.Vt);
    }
    barsInLogicalRange(t) {
      if (null === t)
        return null;
      const i = new yn(new xn(t.from, t.to)).lu(), n = this.Es.In();
      if (n.Ni())
        return null;
      const s = n.ll(i.Os(), 1), e2 = n.ll(i.ui(), -1), r2 = b(n.el()), h2 = b(n.An());
      if (null !== s && null !== e2 && s.ee > e2.ee)
        return { barsBefore: t.from - r2, barsAfter: h2 - t.to };
      const l2 = { barsBefore: null === s || s.ee === r2 ? t.from - r2 : s.ee - r2, barsAfter: null === e2 || e2.ee === h2 ? h2 - t.to : h2 - e2.ee };
      return null !== s && null !== e2 && (l2.from = s.zb, l2.to = e2.zb), l2;
    }
    setData(t) {
      this.q_, this.Es.Qh(), this.cw.pw(this.Es, t), this.mw("full");
    }
    update(t) {
      this.Es.Qh(), this.cw.bw(this.Es, t), this.mw("update");
    }
    dataByIndex(t, i) {
      const n = this.Es.In().ll(t, i);
      if (null === n)
        return null;
      return ce(this.seriesType())(n);
    }
    data() {
      const t = ce(this.seriesType());
      return this.Es.In().ne().map((i) => t(i));
    }
    subscribeDataChanged(t) {
      this.uw.l(t);
    }
    unsubscribeDataChanged(t) {
      this.uw.v(t);
    }
    setMarkers(t) {
      this.q_;
      const i = t.map((t2) => xe(t2, this.q_.convertHorzItemToInternal(t2.time), t2.time));
      this.Es.na(i);
    }
    markers() {
      return this.Es.sa().map((t) => xe(t, t.originalTime, void 0));
    }
    applyOptions(t) {
      this.Es.$h(t);
    }
    options() {
      return z(this.Es.W());
    }
    priceScale() {
      return this.dw.priceScale(this.Es.Dt().Pa());
    }
    createPriceLine(t) {
      const i = V(z(Se), t), n = this.Es.ea(i);
      return new ke(n);
    }
    removePriceLine(t) {
      this.Es.ra(t._w());
    }
    seriesType() {
      return this.Es.Qh();
    }
    attachPrimitive(t) {
      this.Es.ka(t), t.attached && t.attached({ chart: this.fw, series: this, requestUpdate: () => this.Es.$t().Kl() });
    }
    detachPrimitive(t) {
      this.Es.ya(t), t.detached && t.detached();
    }
    mw(t) {
      this.uw.M() && this.uw.m(t);
    }
  };
  var Ce = class {
    constructor(t, i, n) {
      this.ww = new D(), this.mu = new D(), this.Om = new D(), this.$i = t, this.yl = t.St(), this.ab = i, this.yl.nc().l(this.gw.bind(this)), this.yl.sc().l(this.Mw.bind(this)), this.ab.Nm().l(this.xw.bind(this)), this.q_ = n;
    }
    S() {
      this.yl.nc().p(this), this.yl.sc().p(this), this.ab.Nm().p(this), this.ww.S(), this.mu.S(), this.Om.S();
    }
    scrollPosition() {
      return this.yl.Hu();
    }
    scrollToPosition(t, i) {
      i ? this.yl.Ju(t, 1e3) : this.$i.Jn(t);
    }
    scrollToRealTime() {
      this.yl.Gu();
    }
    getVisibleRange() {
      const t = this.yl.Vu();
      return null === t ? null : { from: t.from.originalTime, to: t.to.originalTime };
    }
    setVisibleRange(t) {
      const i = { from: this.q_.convertHorzItemToInternal(t.from), to: this.q_.convertHorzItemToInternal(t.to) }, n = this.yl.Iu(i);
      this.$i.pd(n);
    }
    getVisibleLogicalRange() {
      const t = this.yl.Du();
      return null === t ? null : { from: t.Os(), to: t.ui() };
    }
    setVisibleLogicalRange(t) {
      p(t.from <= t.to, "The from index cannot be after the to index."), this.$i.pd(t);
    }
    resetTimeScale() {
      this.$i.Kn();
    }
    fitContent() {
      this.$i.hc();
    }
    logicalToCoordinate(t) {
      const i = this.$i.St();
      return i.Ni() ? null : i.It(t);
    }
    coordinateToLogical(t) {
      return this.yl.Ni() ? null : this.yl.Nu(t);
    }
    timeToCoordinate(t) {
      const i = this.q_.convertHorzItemToInternal(t), n = this.yl.Va(i, false);
      return null === n ? null : this.yl.It(n);
    }
    coordinateToTime(t) {
      const i = this.$i.St(), n = i.Nu(t), s = i.Ui(n);
      return null === s ? null : s.originalTime;
    }
    width() {
      return this.ab.um().width;
    }
    height() {
      return this.ab.um().height;
    }
    subscribeVisibleTimeRangeChange(t) {
      this.ww.l(t);
    }
    unsubscribeVisibleTimeRangeChange(t) {
      this.ww.v(t);
    }
    subscribeVisibleLogicalRangeChange(t) {
      this.mu.l(t);
    }
    unsubscribeVisibleLogicalRangeChange(t) {
      this.mu.v(t);
    }
    subscribeSizeChange(t) {
      this.Om.l(t);
    }
    unsubscribeSizeChange(t) {
      this.Om.v(t);
    }
    applyOptions(t) {
      this.yl.$h(t);
    }
    options() {
      return Object.assign(Object.assign({}, z(this.yl.W())), { barSpacing: this.yl.le() });
    }
    gw() {
      this.ww.M() && this.ww.m(this.getVisibleRange());
    }
    Mw() {
      this.mu.M() && this.mu.m(this.getVisibleLogicalRange());
    }
    xw(t) {
      this.Om.m(t.width, t.height);
    }
  };
  function Te(t) {
    if (void 0 === t || "custom" === t.type)
      return;
    const i = t;
    void 0 !== i.minMove && void 0 === i.precision && (i.precision = function(t2) {
      if (t2 >= 1)
        return 0;
      let i2 = 0;
      for (; i2 < 8; i2++) {
        const n = Math.round(t2);
        if (Math.abs(n - t2) < 1e-8)
          return i2;
        t2 *= 10;
      }
      return i2;
    }(i.minMove));
  }
  function Pe(t) {
    return function(t2) {
      if (I(t2.handleScale)) {
        const i2 = t2.handleScale;
        t2.handleScale = { axisDoubleClickReset: { time: i2, price: i2 }, axisPressedMouseMove: { time: i2, price: i2 }, mouseWheel: i2, pinch: i2 };
      } else if (void 0 !== t2.handleScale) {
        const { axisPressedMouseMove: i2, axisDoubleClickReset: n } = t2.handleScale;
        I(i2) && (t2.handleScale.axisPressedMouseMove = { time: i2, price: i2 }), I(n) && (t2.handleScale.axisDoubleClickReset = { time: n, price: n });
      }
      const i = t2.handleScroll;
      I(i) && (t2.handleScroll = { horzTouchDrag: i, vertTouchDrag: i, mouseWheel: i, pressedMouseMove: i });
    }(t), t;
  }
  var Re = class {
    constructor(t, i, n) {
      this.Sw = /* @__PURE__ */ new Map(), this.kw = /* @__PURE__ */ new Map(), this.yw = new D(), this.Cw = new D(), this.Tw = new D(), this.Pw = new se(i);
      const s = void 0 === n ? z(ge()) : V(z(ge()), Pe(n));
      this.q_ = i, this.aw = new Fs(t, s, i), this.aw.lm().l((t2) => {
        this.yw.M() && this.yw.m(this.Rw(t2()));
      }, this), this.aw.am().l((t2) => {
        this.Cw.M() && this.Cw.m(this.Rw(t2()));
      }, this), this.aw.Xc().l((t2) => {
        this.Tw.M() && this.Tw.m(this.Rw(t2()));
      }, this);
      const e2 = this.aw.$t();
      this.Dw = new Ce(e2, this.aw.fb(), this.q_);
    }
    remove() {
      this.aw.lm().p(this), this.aw.am().p(this), this.aw.Xc().p(this), this.Dw.S(), this.aw.S(), this.Sw.clear(), this.kw.clear(), this.yw.S(), this.Cw.S(), this.Tw.S(), this.Pw.S();
    }
    resize(t, i, n) {
      this.autoSizeActive() || this.aw._b(t, i, n);
    }
    addCustomSeries(t, i) {
      const n = w(t), s = Object.assign(Object.assign({}, _), n.defaultOptions());
      return this.Vw("Custom", s, i, n);
    }
    addAreaSeries(t) {
      return this.Vw("Area", l, t);
    }
    addBaselineSeries(t) {
      return this.Vw("Baseline", a, t);
    }
    addBarSeries(t) {
      return this.Vw("Bar", r, t);
    }
    addCandlestickSeries(t = {}) {
      return function(t2) {
        void 0 !== t2.borderColor && (t2.borderUpColor = t2.borderColor, t2.borderDownColor = t2.borderColor), void 0 !== t2.wickColor && (t2.wickUpColor = t2.wickColor, t2.wickDownColor = t2.wickColor);
      }(t), this.Vw("Candlestick", e, t);
    }
    addHistogramSeries(t) {
      return this.Vw("Histogram", o, t);
    }
    addLineSeries(t) {
      return this.Vw("Line", h, t);
    }
    removeSeries(t) {
      const i = m(this.Sw.get(t)), n = this.Pw.vd(i);
      this.aw.$t().vd(i), this.Ow(n), this.Sw.delete(t), this.kw.delete(i);
    }
    pw(t, i) {
      this.Ow(this.Pw.Kb(t, i));
    }
    bw(t, i) {
      this.Ow(this.Pw.iw(t, i));
    }
    subscribeClick(t) {
      this.yw.l(t);
    }
    unsubscribeClick(t) {
      this.yw.v(t);
    }
    subscribeCrosshairMove(t) {
      this.Tw.l(t);
    }
    unsubscribeCrosshairMove(t) {
      this.Tw.v(t);
    }
    subscribeDblClick(t) {
      this.Cw.l(t);
    }
    unsubscribeDblClick(t) {
      this.Cw.v(t);
    }
    priceScale(t) {
      return new Me(this.aw, t);
    }
    timeScale() {
      return this.Dw;
    }
    applyOptions(t) {
      this.aw.$h(Pe(t));
    }
    options() {
      return this.aw.W();
    }
    takeScreenshot() {
      return this.aw.wb();
    }
    autoSizeActive() {
      return this.aw.kb();
    }
    chartElement() {
      return this.aw.yb();
    }
    paneSize() {
      const t = this.aw.Tb();
      return { height: t.height, width: t.width };
    }
    setCrosshairPosition(t, i, n) {
      const s = this.Sw.get(n);
      if (void 0 === s)
        return;
      const e2 = this.aw.$t().dr(s);
      null !== e2 && this.aw.$t().ad(t, i, e2);
    }
    clearCrosshairPosition() {
      this.aw.$t().od(true);
    }
    Vw(t, i, n = {}, s) {
      Te(n.priceFormat);
      const e2 = V(z(u), z(i), n), r2 = this.aw.$t().dd(t, e2, s), h2 = new ye(r2, this, this, this, this.q_);
      return this.Sw.set(h2, r2), this.kw.set(r2, h2), h2;
    }
    Ow(t) {
      const i = this.aw.$t();
      i._d(t.St.Eu, t.St.hw, t.St.lw), t.ew.forEach((t2, i2) => i2.J(t2.$e, t2.rw)), i.Wu();
    }
    Bw(t) {
      return m(this.kw.get(t));
    }
    Rw(t) {
      const i = /* @__PURE__ */ new Map();
      t.Nb.forEach((t2, n2) => {
        const s = n2.Qh(), e2 = ce(s)(t2);
        if ("Custom" !== s)
          p(js(e2));
        else {
          const t3 = n2.Ta();
          p(!t3 || false === t3(e2));
        }
        i.set(this.Bw(n2), e2);
      });
      const n = void 0 !== t.Eb && this.kw.has(t.Eb) ? this.Bw(t.Eb) : void 0;
      return { time: t.zb, logical: t.ee, point: t.Lb, hoveredSeries: n, hoveredObjectId: t.Fb, seriesData: i, sourceEvent: t.Wb };
    }
  };
  function De(t, i, n) {
    let s;
    if (A(t)) {
      const i2 = document.getElementById(t);
      p(null !== i2, `Cannot find element in DOM with id=${t}`), s = i2;
    } else
      s = t;
    const e2 = new Re(s, i, n);
    return i.setOptions(e2.options()), e2;
  }
  function Ve(t, i) {
    return De(t, new is(), is.Id(i));
  }
  var Be = Object.assign(Object.assign({}, u), _);

  // js/chart_hook.js
  var chart = null;
  var candleSeries = null;
  var smaTinySeries = null;
  var smaMediumSeries = null;
  var yinLeafMarkers = [];
  var yangLeafMarkers = [];
  var yinBranchMarkers = [];
  var yangBranchMarkers = [];
  var ChartHook = {
    mounted() {
      this.initChart();
      this.updateChart();
    },
    updated() {
      this.updateChart();
    },
    destroyed() {
      if (chart) {
        chart.remove();
        chart = null;
      }
    },
    initChart() {
      const container = this.el;
      chart = Ve(container, {
        width: container.clientWidth,
        height: 600,
        layout: {
          background: { color: "#ffffff" },
          textColor: "#333"
        },
        grid: {
          vertLines: { color: "#f0f0f0" },
          horzLines: { color: "#f0f0f0" }
        },
        crosshair: {
          mode: 1
          // Normal
        },
        rightPriceScale: {
          borderColor: "#d1d4dc"
        },
        timeScale: {
          borderColor: "#d1d4dc",
          timeVisible: true,
          secondsVisible: false
        }
      });
      candleSeries = chart.addCandlestickSeries({
        upColor: "#26a69a",
        downColor: "#ef5350",
        borderVisible: false,
        wickUpColor: "#26a69a",
        wickDownColor: "#ef5350"
      });
      smaTinySeries = chart.addLineSeries({
        color: "#2196F3",
        lineWidth: 1,
        title: "SMA Tiny",
        priceFormat: { type: "price", precision: 2, minMove: 0.01 }
      });
      smaMediumSeries = chart.addLineSeries({
        color: "#FF9800",
        lineWidth: 1,
        title: "SMA Medium",
        priceFormat: { type: "price", precision: 2, minMove: 0.01 }
      });
      window.addEventListener("resize", () => {
        chart.applyOptions({ width: container.clientWidth });
      });
    },
    updateChart() {
      if (!chart || !candleSeries)
        return;
      const barsData = JSON.parse(this.el.dataset.bars || "[]");
      const leavesData = JSON.parse(this.el.dataset.leaves || "[]");
      const branchesData = JSON.parse(this.el.dataset.branches || "[]");
      if (barsData.length === 0)
        return;
      const bars = barsData.slice().reverse().map((b2) => ({
        time: b2.time,
        open: b2.open,
        high: b2.high,
        low: b2.low,
        close: b2.close
      }));
      const smaTiny = barsData.slice().reverse().map((b2) => ({
        time: b2.time,
        value: b2.sma_tiny
      }));
      const smaMedium = barsData.slice().reverse().map((b2) => ({
        time: b2.time,
        value: b2.sma_medium
      }));
      candleSeries.setData(bars);
      smaTinySeries.setData(smaTiny);
      smaMediumSeries.setData(smaMedium);
      this.updateLeafMarkers(leavesData, barsData);
      this.updateBranchMarkers(branchesData, barsData);
    },
    updateLeafMarkers(leaves, bars) {
      [...yinLeafMarkers, ...yangLeafMarkers].forEach((m2) => chart.removeSeries(m2));
      yinLeafMarkers = [];
      yangLeafMarkers = [];
      leaves.filter((l2) => l2.type === "yin").forEach((leaf) => {
        const bar = bars.find((b2) => b2.time === leaf.time);
        if (!bar)
          return;
        const series = chart.addSeries(
          chart.constructor.CustomSeries,
          {
            priceFormat: { type: "price", precision: 2, minMove: 0.01 }
          }
        );
        series.setData([{
          time: leaf.time,
          position: "belowBar",
          color: "#4CAF50",
          shape: "arrowUp",
          text: "Yin Leaf",
          size: 12
        }]);
        yinLeafMarkers.push(series);
      });
      leaves.filter((l2) => l2.type === "yang").forEach((leaf) => {
        const bar = bars.find((b2) => b2.time === leaf.time);
        if (!bar)
          return;
        const series = chart.addSeries(
          chart.constructor.CustomSeries,
          {
            priceFormat: { type: "price", precision: 2, minMove: 0.01 }
          }
        );
        series.setData([{
          time: leaf.time,
          position: "aboveBar",
          color: "#F44336",
          shape: "arrowDown",
          text: "Yang Leaf",
          size: 12
        }]);
        yangLeafMarkers.push(series);
      });
    },
    updateBranchMarkers(branches, bars) {
      [...yinBranchMarkers, ...yangBranchMarkers].forEach((m2) => chart.removeSeries(m2));
      yinBranchMarkers = [];
      yangBranchMarkers = [];
      branches.filter((b2) => b2.type === "yin").forEach((branch) => {
        const entryBar = bars.find((b2) => b2.time === branch.time);
        if (!entryBar)
          return;
        const series = chart.addSeries(
          chart.constructor.CustomSeries,
          { priceFormat: { type: "price", precision: 2, minMove: 0.01 } }
        );
        series.setData([{
          time: branch.time,
          position: "belowBar",
          color: "#4CAF50",
          shape: "circle",
          text: `Yin Branch
Entry: ${branch.start_idx}
Exit: ${branch.exit_idx}`,
          size: 16
        }]);
        yinBranchMarkers.push(series);
      });
      branches.filter((b2) => b2.type === "yang").forEach((branch) => {
        const entryBar = bars.find((b2) => b2.time === branch.time);
        if (!entryBar)
          return;
        const series = chart.addSeries(
          chart.constructor.CustomSeries,
          { priceFormat: { type: "price", precision: 2, minMove: 0.01 } }
        );
        series.setData([{
          time: branch.time,
          position: "aboveBar",
          color: "#F44336",
          shape: "circle",
          text: `Yang Branch
Entry: ${branch.start_idx}
Exit: ${branch.exit_idx}`,
          size: 16
        }]);
        yangBranchMarkers.push(series);
      });
    }
  };

  // js/app.js
  var Hooks2 = { ChartHook };
  var liveSocket = new LiveSocket("/live", Socket, {
    hooks: Hooks2,
    params: { _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute("content") }
  });
  liveSocket.connect();
  window.liveSocket = liveSocket;
})();
/*! Bundled license information:

lightweight-charts/dist/lightweight-charts.production.mjs:
  (*!
   * @license
   * TradingView Lightweight Charts™ v4.2.3
   * Copyright (c) 2025 TradingView, Inc.
   * Licensed under Apache License 2.0 https://www.apache.org/licenses/LICENSE-2.0
   *)
*/
