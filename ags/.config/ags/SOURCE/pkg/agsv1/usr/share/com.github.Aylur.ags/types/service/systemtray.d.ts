import Gio from 'gi://Gio';
import Gdk from 'gi://Gdk?version=3.0';
import GdkPixbuf from 'gi://GdkPixbuf';
import DbusmenuGtk3 from 'gi://DbusmenuGtk3';
import Service from '../service.js';
export declare class TrayItem extends Service {
    private _proxy;
    private _busName;
    private _iconTheme?;
    menu?: DbusmenuGtk3.Menu;
    constructor(busName: string, objectPath: string);
    readonly activate: (event: Gdk.Event) => void;
    readonly secondaryActivate: (event: Gdk.Event) => void;
    readonly scroll: (event: Gdk.EventScroll) => void;
    readonly openMenu: (event: Gdk.Event) => void;
    get category(): string;
    get id(): string;
    get title(): string;
    get status(): string;
    get window_id(): number;
    get is_menu(): boolean;
    get tooltip_markup(): string;
    get icon(): string | GdkPixbuf.Pixbuf;
    private _itemProxyAcquired;
    private _notify;
    private _refreshAllProperties;
    private _getPixbuf;
}
export declare class SystemTray extends Service {
    private _dbus;
    private _items;
    get IsStatusNotifierHostRegistered(): boolean;
    get ProtocolVersion(): number;
    get RegisteredStatusNotifierItems(): string[];
    get items(): TrayItem[];
    readonly getItem: (name: string) => TrayItem | undefined;
    constructor();
    private _register;
    RegisterStatusNotifierItemAsync(serviceName: string[], invocation: Gio.DBusMethodInvocation): void;
}
export declare const systemTray: SystemTray;
export default systemTray;
