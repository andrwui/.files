import { type BaseProps, type Widget } from './widget.js';
import Gtk from 'gi://Gtk?version=3.0';
export type ListBoxProps<Attr = unknown, Self = ListBox<Attr>> = BaseProps<Self, Gtk.ListBox.ConstructorProperties, Attr>;
export declare function newListBox<Attr = unknown>(...props: ConstructorParameters<typeof ListBox<Attr>>): ListBox<Attr>;
export interface ListBox<Attr> extends Widget<Attr> {
}
export declare class ListBox<Attr> extends Gtk.ListBox {
    constructor(props?: ListBoxProps<Attr>);
}
export default ListBox;
