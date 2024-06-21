import { Component, ReactNode } from "react";
import React from "react";

interface SearchParent {
  updateSearchString(v: string): void;
}

type PropsType = {
  searchString: string;
  searchParent: SearchParent;
};

export class ComponentSearchComponent extends Component<PropsType, any, any> {
  handleChange = (e: any) => {
    e.preventDefault();
    this.props.searchParent.updateSearchString(e.target.value);
  };

  public render(): ReactNode {
    return <div className="componentSearch">
      <label>Search: <input type="text" value={this.props.searchString} onChange={this.handleChange}></input></label>
    </div>;
  }
}