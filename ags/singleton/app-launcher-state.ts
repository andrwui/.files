import { Accessor, createState, State } from 'ags'
import { DynamicBarState } from '../widget/dynamic-bar/DynamicBar'

export default class LauncherStateContext {
  private static instance: LauncherStateContext
  private launcherState: State<boolean> = createState<boolean>(false)

  private constructor() {}

  public static getInstance(): LauncherStateContext {
    if (!LauncherStateContext.instance) {
      LauncherStateContext.instance = new LauncherStateContext()
    }
    return LauncherStateContext.instance
  }

  public get(): Accessor<boolean> {
    return this.launcherState[0]
  }

  public set(value: boolean): void {
    this.launcherState[1](value)
  }
}
