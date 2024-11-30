import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
export type MenuBarProps<Attr = unknown, Self = MenuBar<Attr>> = BaseProps<Self, Gtk.MenuBar.ConstructorProperties, Attr>;
export declare function newMenuBar<Attr = unknown>(...props: ConstructorParameters<typeof MenuBar<Attr>>): MenuBar<Attr>;
export interface MenuBar<Attr> extends Widget<Attr> {
}
export declare class MenuBar<Attr> extends Gtk.MenuBar {
    constructor(props?: MenuBarProps<Attr>);
}
export default MenuBar;
