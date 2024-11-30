import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
type Event<Self> = (self: Self) => void | boolean;
export type ToggleButtonProps<Child extends Gtk.Widget = Gtk.Widget, Attr = unknown, Self = ToggleButton<Child, Attr>> = BaseProps<Self, Gtk.ToggleButton.ConstructorProperties & {
    child?: Child;
    on_toggled?: Event<Self>;
}, Attr>;
export declare function newToggleButton<Child extends Gtk.Widget = Gtk.Widget, Attr = unknown>(...props: ConstructorParameters<typeof ToggleButton<Child, Attr>>): ToggleButton<Child, Attr>;
export interface ToggleButton<Child, Attr> extends Widget<Attr> {
}
export declare class ToggleButton<Child extends Gtk.Widget, Attr> extends Gtk.ToggleButton {
    constructor(props?: ToggleButtonProps<Child, Attr>, child?: Child);
    get child(): Child;
    set child(child: Child);
    get on_toggled(): Event<this>;
    set on_toggled(callback: Event<this>);
}
export {};
