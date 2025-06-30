import { bind, Binding, Variable } from 'astal'
import Gdk from 'gi://Gdk?version=3.0'

export enum NotchStateType {
  NORMAL = 'normal',
  HOVERED = 'hovered',
  APP_LAUNCHER = 'app_launcher',
  NOTIFICATION = 'notification',
  POWER_MENU = 'power_menu',
}

export default class NotchState {
  private static instances = new WeakMap<Gdk.Monitor, NotchState>()
  private notchState = Variable<NotchStateType>(NotchStateType.NORMAL)

  private constructor() { }

  public static getInstance(monitor: Gdk.Monitor): NotchState {
    if (!this.instances.has(monitor)) this.instances.set(monitor, new NotchState())
    return this.instances.get(monitor)!
  }

  public get(): Binding<NotchStateType> {
    return bind(this.notchState).as(() => this.notchState.get())
  }

  public set(state: NotchStateType): void {
    this.notchState.set(state)
  }
}
