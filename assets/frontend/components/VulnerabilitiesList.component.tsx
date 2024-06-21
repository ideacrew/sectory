import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "../data/cyclone_data_loader";
import { VulnerabilityComponent } from "./Vulnerability.component"
import * as CycloneModel from "../cyclonedx/models";
import * as cdx from "@cyclonedx/cyclonedx-library";
import { VulnerabilitiesSummaryComponent } from "./VulnerabilitiesSummary.component";
import React from "react";

type PropsType = {
  dataLoader: CycloneDataLoader;
};

export class VulnerabilitiesListComponent extends Component<PropsType, any, any> {

  formatSeverity(vuln: CycloneModel.Vulnerability) {
    if (vuln.ratings) {
      const ratings = vuln.ratings;
      if (ratings.length > 0) {
        let sortedRatings = ratings.sort((a, b) => {
          return CycloneModel.severitySort(a.severity) - CycloneModel.severitySort(b.severity);
        });
        return sortedRatings[0].severity;
      }
    }
    return cdx.Enums.Vulnerability.Severity.Unknown;
  }

  sortVulns(vulns: Array<CycloneModel.Vulnerability>) {
    return vulns.sort((a, b) => {
      return CycloneModel.severitySort(this.formatSeverity(b)) - CycloneModel.severitySort(this.formatSeverity(a));
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
          return <VulnerabilityComponent vulnerability={v} dataLoader={this.props.dataLoader} key={v["bom-ref"] + "vuln-row"}></VulnerabilityComponent>
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