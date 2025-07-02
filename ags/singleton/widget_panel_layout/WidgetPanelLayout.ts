import { bind, Binding, Variable } from 'astal'

export enum WidgetPanelLayoutType {
  HOME = 'home',
  BLUETOOTH = 'bluetooth',
  // NETWORK = 'network'
  // AUDIO = 'audio'
}

export default class WidgetPanelLayout {
  private static instance: WidgetPanelLayout
  private widgetPanelLayout: Variable<WidgetPanelLayoutType> = Variable<WidgetPanelLayoutType>(
    WidgetPanelLayoutType.HOME,
  )

  private constructor() {}

  public static getInstance(): WidgetPanelLayout {
    if (!WidgetPanelLayout.instance) {
      WidgetPanelLayout.instance = new WidgetPanelLayout()
    }
    return WidgetPanelLayout.instance
  }

  public get(): Binding<WidgetPanelLayoutType> {
    return bind(this.widgetPanelLayout).as((layout) => {
      return layout
    })
  }
  public set(layout: WidgetPanelLayoutType): void {
    this.widgetPanelLayout.set(layout)
  }
}
