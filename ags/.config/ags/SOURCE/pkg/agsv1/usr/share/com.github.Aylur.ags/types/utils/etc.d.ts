import Gtk from 'gi://Gtk?version=3.0';
import GObject from 'gi://GObject';
export declare function loadInterfaceXML(iface: string): string | null;
export declare function bulkConnect(service: GObject.Object, list: Array<[event: string, callback: (...args: any[]) => void]>): number[];
export declare function bulkDisconnect(service: GObject.Object, ids: number[]): void;
export declare function lookUpIcon(name?: string, size?: number): Gtk.IconInfo | null;
export declare function ensureDirectory(path: string): void;
