package main

import w "core:sys/windows"

L :: w.L

WM_USER :: w.WM_USER

IDHOT_SNAPDESKTOP :: -2 // The "snap desktop" hot key was pressed.
IDHOT_SNAPWINDOW :: -1 // The "snap window" hot key was pressed.

MOD_ALT :: 0x0001 	// Either ALT key must be held down.
MOD_CONTROL :: 0x0002 // Either CTRL key must be held down.
MOD_NOREPEAT :: 0x4000 // Changes the hotkey behavior so that the keyboard auto-repeat does not yield multiple hotkey notifications. Windows Vista: This flag is not supported.
MOD_SHIFT :: 0x0004 // Either SHIFT key must be held down.
MOD_WIN :: 0x0008 // Either WINDOWS key must be held down. These keys are labeled with the Windows logo. Keyboard shortcuts that involve the WINDOWS key are reserved for use by the operating system.

Hotkey_Modifier :: enum w.UINT {
	Alt = MOD_ALT,
	Control = MOD_CONTROL,
	No_Repeat = MOD_NOREPEAT,
	Shift = MOD_SHIFT,
	Win = MOD_WIN
}

// https://learn.microsoft.com/en-us/windows/win32/inputdev/wm-appcommand
App_Command :: enum w.WORD {
	Bass_Boost = 20,
	Bass_Down = 19,
	Browser_Backward = 1,
	Browser_Favourites = 6,
	Browser_Forward = 2,
	Browser_Home = 7,
	Browser_Refresh = 3,
	Browser_Search = 5,
	Browser_Stop_Download = 4,
	Close = 31, // Close the window (not the application).
	Copy = 36, // Copy the selection.
	Correction_List = 45, // Brings up the correction list when a word is incorrectly identified during speech input.
	Cut = 37,
	Dictate_or_Command_Control_Toggle = 43, // Toggles between two modes of speech input: dictation and command/control (giving commands to an application or accessing menus).
	Find = 28,
	Forward_Mail = 40,
	Help = 27,
	Launch_App_1 = 17,
	Launch_App_2 = 18,	
	Launch_Mail = 15,
	Launch_Media_Select = 16,
	Media_Channel_Down = 52, // Decrement the channel value, for example, for a TV or radio tuner.
	Media_Channel_Up = 51, // Increment the channel value, for example, for a TV or radio tuner.
	Media_Fast_Forward = 49,
	Media_Next_Track = 11,
	Media_Pause = 47,
	Media_Play = 46,
	Media_Play_Pause = 14,
	Media_Previous_Track = 12,
	Media_Record = 48,
	Media_Rewind = 50,
	Media_Stop = 13,
	Mic_On_Off_Toggle = 44,
	Microphone_Volume_Down = 25,
	Microphone_Volume_Up = 26,	
	Microphone_Volume_Mute = 24,
	New =  29, // Create a new window.
	Open = 30, // Open a window
	Paste = 38,
	Print = 33,
	Redo = 35,
	Reply_To_Mail = 39,
	Save = 32,
	Send_Mail = 41,
	Spell_Check = 42,
	Treble_Down = 22,
	Treble_Up = 23,
	Undo = 34,
	Volume_Down = 9,
	Volume_Mute = 8,
	Volume_Up = 10
}

FAPPCOMMAND_KEY :: 0 // User pressed a key.
FAPPCOMMAND_MOUSE :: 0x8000 // User clicked a mouse button.
FAPPCOMMAND_OEM :: 0x1000 // An unidentified hardware source generated the event. It could be a mouse or a keyboard event.

INITCOMMONCONTROLSEX :: struct {
	dwSize: w.DWORD,
	dwICC: Init_Common_Controls_Flags,
}

Init_Common_Controls_Flags :: enum w.DWORD {
	Animate = 0x00000080,
	Bar = 0x00000004,
	Cool = 0x00000400,
	Date = 0x00000100,
	Hotkey = 0x00000040,
	Internet = 0x00000800,
	Link = 0x00008000,
	List_View = 0x00000001,
	Native_Font_Control = 0x00002000,
	Pages_Scroller = 0x00001000,
	Progress = 0x00000020,
	Standard = 0x00004000,
	Tab = 0x00000008,
	Tree_View = 0x00000002,
	Up_Down = 0x00000010,
	User_Ex = 0x00000200,
	Win_95 = 0x000000FF
}

Notification_Icon_Message :: enum w.DWORD {
	Add = 0x00000000,
	Modify = 0x00000001,
	Delete = 0x00000002,
	Set_Focus = 0x00000003,
	Set_Version = 0x00000004,
}

Notification_Icon_Flags :: enum w.UINT {
	Message = 0x00000001, // The uCallbackMessage member is valid.
	Icon = 0x00000002, // The hIcon member is valid.
	Tip = 0x00000004, //The szTip member is valid.
	State = 0x00000008, //The dwState and dwStateMask members are valid.
	Info = 0x00000010, // Display a balloon notification. The szInfo, szInfoTitle, dwInfoFlags, and uTimeout members are valid. Note that uTimeout is valid only in Windows 2000 and Windows XP.
    //To display the balloon notification, specify NIF_INFO and provide text in szInfo.
    //To remove a balloon notification, specify NIF_INFO and provide an empty string through szInfo.
    //To add a notification area icon without displaying a notification, do not set the NIF_INFO flag.
    Guid = 0x00000020, // 0x00000020. 
    Real_Time = 0x00000040, // f the balloon notification cannot be displayed immediately, discard it. Use this flag for notifications that represent real-time information which would be meaningless or misleading if displayed at a later time. For example, a message that states "Your telephone is ringing." NIF_REALTIME is meaningful only when combined with the NIF_INFO flag.
    Show_Tip = 0x00000080, // Use the standard tooltip. Normally, when uVersion is set to NOTIFYICON_VERSION_4, the standard tooltip is suppressed and can be replaced by the application-drawn, pop-up UI. If the application wants to show the standard tooltip with NOTIFYICON_VERSION_4, it can specify NIF_SHOWTIP to indicate the standard tooltip should still be shown.
}

NOTIFYICONDATAW_DUMMYUNIONNAME :: struct #raw_union {
	uTimeout: w.UINT,
	uVersion: w.UINT,
}

NOTIFYICONDATAW :: struct {
	cbSize: w.DWORD,
	hwnd: w.HWND,
	id: w.UINT,
	flags: Notification_Icon_Flags,
	uCallbackMessage: w.UINT,
	hIcon: w.HICON,
	szTip: [64]u16,
	dwState: w.DWORD,
	dwStateMask: w.DWORD,
	szInfo: [256]u16,
	versionOrTimeout: w.UINT,
	szInfoTitle: [64]u16,
	dwInfoFlags: w.DWORD,
	guidItem: GUID,
	hBalloonIcon: w.HICON,
}

GUID :: struct {
	data1: u32,
	data2: u16,
	data3: u16,
	data4: [8]u8,
}

foreign import User32 "system:User32.lib" 
@(default_calling_convention="stdcall")
foreign User32 {
	RegisterHotKey :: proc(hwnd: w.HWND, id: i32, fsModifiers: Hotkey_Modifier, vk: w.UINT) -> w.BOOL ---
	UnregisterHotKey :: proc(hwnd: w.HWND, id: i32) -> w.BOOL ---
	LoadMenuW :: proc(hinst: w.HINSTANCE, lpMenuName: w.LPCWSTR) -> w.HMENU ---
}

foreign import Comctl32 "system:Comctl32.lib" 
@(default_calling_convention="stdcall")
foreign Comctl32 {
	InitCommonControlsEx :: proc(picce: ^INITCOMMONCONTROLSEX) -> w.BOOL ---
}

foreign import Shell32 "system:Shell32.lib" 
@(default_calling_convention="stdcall")
foreign Shell32 {
	Shell_NotifyIconW :: proc(message: Notification_Icon_Message, data: ^NOTIFYICONDATAW) -> w.BOOL ---
}