import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
export type SpinnerProps<Attr = unknown> = BaseProps<Spinner<Attr>, Gtk.Spinner.ConstructorProperties, Attr>;
export declare function newSpinner<Attr = unknown>(...props: ConstructorParameters<typeof Spinner<Attr>>): Spinner<Attr>;
export interface Spinner<Attr> extends Widget<Attr> {
}
export declare class Spinner<Attr> extends Gtk.Spinner {
    constructor(props?: BaseProps<Spinner<Attr>, Gtk.Spinner.ConstructorProperties, Attr>);
}
export default Spinner;
