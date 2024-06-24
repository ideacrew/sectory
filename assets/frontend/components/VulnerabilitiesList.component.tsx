import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "./cyclone_data_loader";
import { VulnerabilityComponent } from "./Vulnerability.component"
import * as CycloneModel from "../cyclonedx/models";
import { VulnerabilitiesSummaryComponent } from "./VulnerabilitiesSummary.component";
import React from 'react';
import { VulnerabilitySearchComponent } from "./VulnerabilitySearch.component";

type PropsType = {
  dataLoader: CycloneDataLoader;
  deliverableVersion: any;
};

type StateType = {
  searchString: string;
  searchValue: string;
}

export class VulnerabilitiesListComponent extends Component<PropsType, StateType, any> {
  public constructor(props: PropsType) {
    super(props);
    this.state = {
      searchString: "",
      searchValue: ""
    };
  }

  sortVulns(vulns: Array<CycloneModel.Vulnerability>) {
    return vulns.sort((a, b) => {
      return CycloneModel.severitySort(CycloneModel.formatSeverity(b)) - CycloneModel.severitySort(CycloneModel.formatSeverity(a));
    });
  }

  public updateSearchString(v: string) : void {
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

  renderVulnerabilities() : ReactNode | string {
    const vulns = this.props.dataLoader.bom?.vulnerabilities;
    if (vulns) {
      if (vulns.length > 0) {
        const sortedVulns = this.sortVulns(vulns);
        return sortedVulns.map(v => {
          return <VulnerabilityComponent deliverableVersion={this.props.deliverableVersion} vulnerability={v} dataLoader={this.props.dataLoader} key={v["bom-ref"] + v["id"] + "vuln-row"} searchValue={this.state.searchValue}></VulnerabilityComponent>
        });
      }
    }
    return "";
  }

  public render(): ReactNode {
    return (
        <Fragment>
        <VulnerabilitiesSummaryComponent dataLoader={this.props.dataLoader}/>
        <VulnerabilitySearchComponent searchParent={this} searchString={this.state.searchString}/>
        <div>
          <table className="vuln-list-table">
            <thead>
             <tr>
              <th>ID</th>
              <th>Description</th>
              <th>Severity</th>
              <th>Score</th>
              <th>Tools</th>
              <th>Details</th>
             </tr>
            </thead>
            <tbody>
              {this.renderVulnerabilities()}
            </tbody>
          </table>
        </div>
        </Fragment>
    );
  }
}