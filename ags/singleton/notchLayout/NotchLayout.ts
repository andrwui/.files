import { bind, Binding, Variable } from 'astal'

export enum NotchLayoutType {
  HOME = 'home',
  BLUETOOTH = 'bluetooth',
  // NETWORK = 'network'
  // AUDIO = 'audio'
}

export default class NotchLayout {
  private static instance: NotchLayout
  private notchLayout: Variable<NotchLayoutType> = Variable<NotchLayoutType>(NotchLayoutType.HOME)

  private constructor() {}

  public static getInstance(): NotchLayout {
    if (!NotchLayout.instance) {
      NotchLayout.instance = new NotchLayout()
    }
    return NotchLayout.instance
  }

  public get(): Binding<NotchLayoutType> {
    return bind(this.notchLayout).as((notchLayout) => {
      return notchLayout
    })
  }
  public set(state: NotchLayoutType): void {
    this.notchLayout.set(state)
  }
}
