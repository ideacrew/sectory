import { Component, ReactNode } from "react";
import { ViewSelection } from "./view_state";
import React from "react";

type PropsType = {
  selectedView: ViewSelection;
  viewSelector: any;
}

export class MenuComponent extends Component<PropsType, any, any> {

  selectComponents = () => this.props.viewSelector(ViewSelection.COMPONENTS);
  selectVulnerabilities = () => this.props.viewSelector(ViewSelection.VULNERABLITIES);

  getClassName(vs: ViewSelection) {
    if (vs === this.props.selectedView) {
      return "selected";
    }
    return "unselected";
  }

  render() : ReactNode {
    return <div className="topMenuItems">
      <ul>
        <li>Software Bill of Materials</li>
        <li onClick={this.selectComponents} className={this.getClassName(ViewSelection.COMPONENTS)}>Components</li>
        <li onClick={this.selectVulnerabilities} className={this.getClassName(ViewSelection.VULNERABLITIES)}>Vulnerabilities</li>
      </ul>
    </div>;
  }
}