import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "./cyclone_data_loader";
import { VulnerabilityComponent } from "./Vulnerability.component"
import * as CycloneModel from "../cyclonedx/models";
import { VulnerabilitiesSummaryComponent } from "./VulnerabilitiesSummary.component";
import React from 'react';

type PropsType = {
  dataLoader: CycloneDataLoader;
};

export class VulnerabilitiesListComponent extends Component<PropsType, any, any> {
  sortVulns(vulns: Array<CycloneModel.Vulnerability>) {
    return vulns.sort((a, b) => {
      return CycloneModel.severitySort(CycloneModel.formatSeverity(b)) - CycloneModel.severitySort(CycloneModel.formatSeverity(a));
    });
  }

  shouldComponentUpdate(_nextProps : PropsType, _nextState : any) {
    return false;
  };

  renderVulnerabilities() : ReactNode | string {
    const vulns = this.props.dataLoader.bom?.vulnerabilities;
    if (vulns) {
      if (vulns.length > 0) {
        const sortedVulns = this.sortVulns(vulns);
        return sortedVulns.map(v => {
          return <VulnerabilityComponent vulnerability={v} dataLoader={this.props.dataLoader} key={v["bom-ref"] + v["id"] + "vuln-row"}></VulnerabilityComponent>
        });
      }
    }
    return "";
  }

  public render(): ReactNode {
    return (
        <Fragment>
        <VulnerabilitiesSummaryComponent dataLoader={this.props.dataLoader}/>
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