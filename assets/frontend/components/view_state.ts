export enum ViewSelection {
  COMPONENTS,
  VULNERABLITIES
}

export type ViewState = {
  selectedView: ViewSelection;
}