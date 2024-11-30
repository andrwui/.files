import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
type Event<Self> = (self: Self) => void | boolean;
export type ColorButtonProps<Child extends Gtk.Widget = Gtk.Widget, Attr = unknown, Self = ColorButton<Child, Attr>> = BaseProps<Self, Gtk.ColorButton.ConstructorProperties & {
    child?: Child;
    on_color_set?: Event<Self>;
}, Attr>;
export declare function newColorButton<Child extends Gtk.Widget = Gtk.Widget, Attr = unknown>(...props: ConstructorParameters<typeof ColorButton<Child, Attr>>): ColorButton<Child, Attr>;
export interface ColorButton<Child, Attr> extends Widget<Attr> {
}
export declare class ColorButton<Child extends Gtk.Widget, Attr> extends Gtk.ColorButton {
    constructor(props?: ColorButtonProps<Child, Attr>, child?: Child);
    get child(): Child;
    set child(child: Child);
    get on_color_set(): Event<this>;
    set on_color_set(callback: Event<this>);
}
export default ColorButton;
