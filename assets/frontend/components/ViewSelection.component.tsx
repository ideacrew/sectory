import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "./cyclone_data_loader";
import { ComponentListComponent } from './ComponentList.component';
import { ViewSelection } from "./view_state";
import { VulnerabilitiesListComponent } from "./VulnerabilitiesList.component";
import * as CycloneModel from "../cyclonedx/models";
import React from "react";

type PropsType = {
  dataLoader: CycloneDataLoader;
  viewState: ViewSelection;
  deliverableVersion: any;
};

export class ViewSelectionComponent extends Component<PropsType, any, any> {
  components() : CycloneModel.Component[] {
    if (this.props.dataLoader.bom?.components) {
      const comps = this.props.dataLoader.bom?.components;
      if (comps.length > 1) {
        return comps;
      }
    }
    return [];
  }

  sectionClass(vs: ViewSelection) {
    if (this.props.viewState === vs) {
      return "shown-section";
    }
    return "hidden-section";
  }

  render() : ReactNode {
      return <Fragment>
      <div className={this.sectionClass(ViewSelection.COMPONENTS)}>
      <ComponentListComponent components={this.components()} />
      </div>
      <div className={this.sectionClass(ViewSelection.VULNERABLITIES)}>
      <VulnerabilitiesListComponent dataLoader={this.props.dataLoader} deliverableVersion={this.props.deliverableVersion}/>
      </div>
      </Fragment>
  }
}