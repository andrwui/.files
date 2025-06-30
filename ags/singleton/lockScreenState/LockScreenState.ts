import { bind, Binding, Variable } from 'astal'

export default class LockScreenState {
  private static instance: LockScreenState
  private lockScreenState: Variable<boolean> = Variable<boolean>(false)

  private constructor() {}

  public static getInstance(): LockScreenState {
    if (!LockScreenState.instance) {
      LockScreenState.instance = new LockScreenState()
    }
    return LockScreenState.instance
  }

  public get(): Binding<boolean> {
    return bind(this.lockScreenState).as((lockScreenState) => {
      return lockScreenState
    })
  }
  public set(state: boolean): void {
    this.lockScreenState.set(state)
  }
}
