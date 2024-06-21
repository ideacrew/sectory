import { Component, ReactNode, Fragment } from "react";
import { ComponentComponent } from "./Component.component";
import * as CycloneModel from "../cyclonedx/models";
import { ComponentSearchComponent } from "./ComponentSearch.component";
import React from "react";

type PropsType = {
  components: CycloneModel.Component[];
}

type StateType = {
  searchString: string;
  searchValue: string;
}

export class ComponentListComponent extends Component<PropsType, StateType, any> {
  constructor(props: PropsType) {
    super(props);
    this.state = {
      searchString: "",
      searchValue: ""
    };
  }

  componentNodes() : Array<ReactNode> | string {
    if (this.props.components.length > 1) {
      let componentDisplay = this.props.components.map((c) => {
        return <ComponentComponent component={c} key={c["bom-ref"] + "-component"} searchValue={this.state.searchValue}></ComponentComponent>;
      })
      return componentDisplay;
    }
    return "";
  }

  public updateSearchString(v: string) {
    this.setState((s) => {
      if (v.length < 2) {
        return {
          ...s,
          searchString: v,
          searchValue: ""
        };
      } else {
        return {
          ...s,
          searchString: v,
          searchValue: v
        };
      }
    });
  }

  public render(): ReactNode {
    return (
      <Fragment>
      <ComponentSearchComponent searchString={this.state.searchString} searchParent={this}/>
      <table className="component-list-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Version</th>
            <th>Kind</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
          { this.componentNodes() }
        </tbody>
      </table>
      </Fragment>
    );
  }
}