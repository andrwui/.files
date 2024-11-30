import Gtk from 'gi://Gtk?version=3.0';
export declare function interval(interval: number, callback: () => void, bind?: Gtk.Widget): number;
export declare function timeout(ms: number, callback: () => void): number;
export declare function idle(callback: () => void, prio?: number): number;
