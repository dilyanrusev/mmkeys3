package main

import w "core:sys/windows"
import "base:runtime"
import "core:log"
import "core:fmt"

Hotkey :: struct {
    command: App_Command,
    vk: u32,
    mod: Hotkey_Modifier,
    is_registered: b32,
}

App :: struct {
    hwnd: w.HWND,
    hinst: w.HINSTANCE,
    hotkeys: []Hotkey
}

app: App = {
    hotkeys = {
        {command=.Volume_Mute,          vk=w.VK_F10,   mod=.Control|.Alt},
        {command=.Volume_Up,            vk=w.VK_F12,   mod=.Control|.Alt},
        {command=.Volume_Down,          vk=w.VK_F11,   mod=.Control|.Alt},
        {command=.Media_Play_Pause,     vk=w.VK_HOME,  mod=.Control|.Alt},
        {command=.Media_Stop,           vk=w.VK_END,   mod=.Control|.Alt},
        {command=.Media_Next_Track,     vk=w.VK_NEXT,  mod=.Control|.Alt},
        {command=.Media_Previous_Track, vk=w.VK_PRIOR, mod=.Control|.Alt},
    }
}

// b73af445-45f8-4e57-a2dd-dbd68a679966
Notify_Icon_Guid: GUID = {0xb73af445,0x45f8,0x4e57,{0xa2, 0xdd, 0xdb, 0xd6, 0x8a, 0x67, 0x99, 0x66}}
App_Title: [^]u16
App_Icon: w.HICON
App_Instance: w.HINSTANCE
App_Notify_Menu: w.HMENU

main :: proc() {
    App_Title = L("MMKeys3")
    App_Instance = transmute(w.HINSTANCE)w.GetModuleHandleW(nil)
    App_Icon = w.LoadIconW(App_Instance, transmute(w.LPCWSTR)IDI_MMKEYS)
    App_Notify_Menu = create_notify_menu()

    cc: INITCOMMONCONTROLSEX
    cc.dwSize = size_of(cc)
    cc.dwICC = .Win_95 | .Standard
    if ok := InitCommonControlsEx(&cc); ok == w.FALSE {
        err := w.GetLastError()
        log.errorf("InitCommonControlsEx failed with %d", err)
    }

    wc: w.WNDCLASSEXW
    wc.cbSize = size_of(wc)
    wc.style = w.CS_HREDRAW|w.CS_VREDRAW
    wc.hbrBackground = transmute(w.HBRUSH)cast(uintptr)(w.COLOR_WINDOW + 1)
    wc.hIcon = App_Icon
    wc.hIconSm = App_Icon
    wc.hInstance = App_Instance
    wc.lpszClassName = w.L("MMKeys3")
    wc.lpfnWndProc = wnd_proc

    if w.RegisterClassExW(&wc) == 0 {
        w.MessageBoxW(nil, w.L("RegisterClassExW failed"), App_Title, w.MB_ICONERROR)
        return
    }

    app.hwnd = w.CreateWindowExW(
        w.WS_EX_OVERLAPPEDWINDOW,
        wc.lpszClassName,
        w.L("MMKeys3"),
        w.WS_CAPTION | w.WS_MINIMIZEBOX | w.WS_SYSMENU,
        w.CW_USEDEFAULT, w.CW_USEDEFAULT,
        w.CW_USEDEFAULT, w.CW_USEDEFAULT,
        nil, nil, wc.hInstance, nil)
    if app.hwnd == nil {
         w.MessageBoxW(nil, w.L("CreateWindowExW failed"), App_Title, w.MB_ICONERROR)
        return
    }

    msg: w.MSG
    for {
        ret := w.GetMessageW(&msg, nil, 0, 0)
        if ret == -1 {
            log.errorf("GetMessageW failed")
        } else if ret == 0 {
            break
        } else {
            w.TranslateMessage(&msg)
            w.DispatchMessageW(&msg)
        }
    }
}

wnd_proc :: proc "stdcall" (hwnd: w.HWND, msg: w.UINT, wparam: w.WPARAM, lparam: w.LPARAM) -> w.LRESULT {
    context = runtime.default_context()

    switch (msg) {
    case w.WM_CREATE:
        cs := transmute(^w.CREATESTRUCTW)lparam
        app.hinst = cs.hInstance
        app.hwnd = hwnd

        for &hk, idx in app.hotkeys {
            ok := RegisterHotKey(hwnd, cast(i32)idx, hk.mod, hk.vk)
            hk.is_registered = ok != w.FALSE
        }

        nid := create_notification_icon(hwnd)
        ok := Shell_NotifyIconW(.Add, &nid)
        if ok == w.FALSE {
            err := w.GetLastError()
            debug_buf: [100]u8
            fmt.bprintf(debug_buf[:], "Shell_NotifyIconW error %d\r\n", err)
            w.OutputDebugStringA(cstring(raw_data(debug_buf[:])))
        }

        return 0

    case w.WM_DESTROY:
        for hk, idx in app.hotkeys {
            if hk.is_registered {
                UnregisterHotKey(hwnd, cast(i32)idx)
            }
        }

        nid := create_notification_icon(hwnd)
        Shell_NotifyIconW(.Delete, &nid)

        app.hwnd = nil

        w.PostQuitMessage(0)
        return 0

    case WM_MMKEYS3_NOTIFY_ICON:
        w.OutputDebugStringA("WM_MMKEYS3_NOTIFY_ICON\r\n")

        notify_message := lparam
        if notify_message == w.WM_RBUTTONDOWN {
            pt: w.POINT
            w.GetCursorPos(&pt)
            w.TrackPopupMenu(App_Notify_Menu, 0, pt.x, pt.y, 0, hwnd, nil)
        } else if notify_message == w.WM_LBUTTONDBLCLK {
            // NOTE: app icon was double-clciked
        }
        return 0

    case w.WM_COMMAND:
        if w.HIWORD(wparam) == 0 {
            id := w.LOWORD(wparam)
            switch id {
                case IDC_MENU_ABOUT:
                    w.MessageBoxW(hwnd, L("MMKeys3 v1.0"), App_Title, w.MB_OK)
                case IDC_MENU_EXIT:
                    w.DestroyWindow(hwnd)
            }
        }
        return 0

    case w.WM_HOTKEY:
        idx := cast(int)wparam
        if idx >= 0 && idx < len(app.hotkeys) {
            hk := &app.hotkeys[idx]
            what: u16 = FAPPCOMMAND_KEY | cast(u16)hk.command
            
            debug_buf: [100]u8
            fmt.bprintf(debug_buf[:], "Sending %v\r\n", hk.command)
            w.OutputDebugStringA(cstring(raw_data(debug_buf[:])))

            w.SendMessageW(hwnd, w.WM_APPCOMMAND, cast(w.WPARAM)hwnd, cast(int)w.MAKELONG(0, what))
        } else {
            log.errorf("App hotkey: uknown")
        }
        return 0

    case:
        return w.DefWindowProcW(hwnd, msg, wparam, lparam)
    }
}

string_copy_from_literal :: proc(dest: []u16, src: [^]u16) {
    dest_len := len(dest)

    i := 0
    for ; i < dest_len; i +=1 {
        if s := src[i]; s != 0 {
            dest[i] = s
        } else {
            dest[i] = 0
            break
        }
    }
    if i == dest_len - 1 {
        dest[i] = 0
    }
}

create_notification_icon :: proc(hwnd: w.HWND) -> NOTIFYICONDATAW {
    nid: NOTIFYICONDATAW
    nid.cbSize = size_of(nid)
    nid.hwnd = hwnd
    nid.flags = .Icon | .Guid | .Tip | .Message
    nid.uCallbackMessage = WM_MMKEYS3_NOTIFY_ICON
    nid.guidItem = Notify_Icon_Guid
    string_copy_from_literal(nid.szTip[:], App_Title)
    nid.hIcon = App_Icon
    return nid
}

create_notify_menu :: proc() -> w.HMENU {
    menu := w.CreatePopupMenu()
    w.AppendMenuW(menu, w.MF_GRAYED | w.MF_DISABLED, 0, App_Title) 
    w.AppendMenuW(menu, 0, IDC_MENU_ABOUT, L("&About"))
    w.AppendMenuW(menu, 0, IDC_MENU_EXIT, L("E&xit"))
    return menu
}