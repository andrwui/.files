import Gio from 'gi://Gio';
export declare function readFile(file: string | Gio.File): string;
export declare function readFileAsync(file: string | Gio.File): Promise<string>;
export declare function writeFile(string: string, path: string): Promise<Gio.File>;
export declare function writeFileSync(string: string, path: string): Gio.File;
export declare function monitorFile(path: string, callback?: (file: Gio.File, event: Gio.FileMonitorEvent) => void, options?: {
    flags: Gio.FileMonitorFlags;
    recursive: boolean;
}): Gio.FileMonitor | null;
