import { Accessor, createBinding, createState, State } from 'ags'
import { DynamicBarState } from '../widget/dynamic-bar/DynamicBar'

export default class DynamicBarStateContext {
  private static instance: DynamicBarStateContext
  private dynamicBarState: State<DynamicBarState> = createState<DynamicBarState>(
    DynamicBarState.WIDGETS,
  )

  private constructor() {}

  public static getInstance(): DynamicBarStateContext {
    if (!DynamicBarStateContext.instance) {
      DynamicBarStateContext.instance = new DynamicBarStateContext()
    }
    return DynamicBarStateContext.instance
  }

  public get(): Accessor<DynamicBarState> {
    return this.dynamicBarState[0]
  }

  public set(value: DynamicBarState): void {
    this.dynamicBarState[1](value)
  }
}
