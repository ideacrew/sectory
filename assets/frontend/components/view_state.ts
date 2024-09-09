export enum ViewSelection {
  COMPONENTS,
  VULNERABLITIES,
  COMPONENT_RISK
}

export type ViewState = {
  selectedView: ViewSelection;
}