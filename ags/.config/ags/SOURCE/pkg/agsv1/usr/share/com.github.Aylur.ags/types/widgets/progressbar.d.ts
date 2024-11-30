import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
export type ProgressBarProps<Attr = unknown, Self = ProgressBar<Attr>> = BaseProps<Self, Gtk.ProgressBar.ConstructorProperties & {
    vertical?: boolean;
    value?: number;
}, Attr>;
export declare function newProgressBar<Attr = unknown>(...props: ConstructorParameters<typeof ProgressBar<Attr>>): ProgressBar<Attr>;
export interface ProgressBar<Attr> extends Widget<Attr> {
}
export declare class ProgressBar<Attr> extends Gtk.ProgressBar {
    constructor(props?: ProgressBarProps<Attr>);
    get value(): number;
    set value(value: number);
    get vertical(): boolean;
    set vertical(v: boolean);
}
export default ProgressBar;
