import { bind, Binding, Variable } from 'astal'

export enum ActionBarLayoutType {
  WIDGETS = 'widgets',
  NOTIFICATION = 'notification',
  APP_LAUNCHER = 'app_launcher',
  POWER_MENU = 'power_menu',
}

export default class ActionBarLayout {
  private static instance: ActionBarLayout
  private actionBarLayout: Variable<ActionBarLayoutType> = Variable<ActionBarLayoutType>(
    ActionBarLayoutType.WIDGETS,
  )

  private constructor() {}

  public static getInstance(): ActionBarLayout {
    if (!ActionBarLayout.instance) {
      ActionBarLayout.instance = new ActionBarLayout()
    }
    return ActionBarLayout.instance
  }

  public get(): Binding<ActionBarLayoutType> {
    return bind(this.actionBarLayout).as((layout) => {
      return layout
    })
  }
  public set(layout: ActionBarLayoutType): void {
    this.actionBarLayout.set(layout)
  }
}
