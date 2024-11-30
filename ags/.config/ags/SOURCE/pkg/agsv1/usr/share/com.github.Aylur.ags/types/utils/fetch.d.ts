import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
export type FetchOptions = {
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
    body?: string;
    headers?: Record<string, string>;
    params?: Record<string, any>;
};
export declare class Response {
    status: number;
    statusText: string | null;
    ok: boolean;
    stream: Gio.InputStream | null;
    type: string;
    constructor(status: number, statusText: string | null, ok: boolean, stream: Gio.InputStream | null);
    json(): Promise<any>;
    text(): Promise<string>;
    arrayBuffer(): Promise<ArrayBuffer | null>;
    gBytes(): Promise<GLib.Bytes | null>;
}
export declare function fetch(url: string, options?: FetchOptions): Promise<Response>;
