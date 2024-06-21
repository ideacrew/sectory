import { Component, Fragment, ReactNode } from "react";
import { CycloneDataLoader } from "../data/cyclone_data_loader";
import * as CycloneModel from "../cyclonedx/models";
import * as cdx from "@cyclonedx/cyclonedx-library";
import React from "react";

type PropsType = {
  dataLoader: CycloneDataLoader;
};

export class VulnerabilitiesSummaryComponent extends Component<PropsType, any, any> {

  countSeverity(sev: cdx.Enums.Vulnerability.Severity) {
    if (this.props.dataLoader.bom?.vulnerabilities) {
      const vulns = this.props.dataLoader.bom?.vulnerabilities;
      if (vulns.length > 0) {
        const matching = vulns.filter((v) => {
          return this.formatSeverity(v) === sev;
        });
        return matching.length;
      }
    }
    return 0;
  }

  countComponentSeverity(sev: cdx.Enums.Vulnerability.Severity) {
    if (this.props.dataLoader.bom?.vulnerabilities) {
      const vulns = this.props.dataLoader.bom?.vulnerabilities;
      if (vulns.length > 0) {
        const matching = vulns.filter((v) => {
          return this.formatSeverity(v) === sev;
        });
        return matching.reduce((acc, m) => {
          let value = 0;
          if (m.affects) {
            value = m.affects.length;
          }
          return acc + value;
        }, 0);
      }
    }
    return 0;
  }

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

  kindSeverityBox(sev: cdx.Enums.Vulnerability.Severity, label: string) {
    let count = this.countSeverity(sev);
    if (count === 0) {
      return "";
    }
    return <div className={"vuln-severity-box " + "vuln-severity-box-" + label.toLowerCase()}>
             <span className="count">{count}</span>
             <span className="label">{label}</span>
           </div>;
  }

  compSeverityBox(sev: cdx.Enums.Vulnerability.Severity, label: string) {
    let count = this.countComponentSeverity(sev);
    if (count === 0) {
      return "";
    }
    return <div className={"vuln-severity-box " + "vuln-severity-box-" + label.toLowerCase()}>
             <span className="count">{count}</span>
             <span className="label">{label}</span>
           </div>;
  }

  public render(): ReactNode {
    return (
        <Fragment>
        <div className="vuln-component-kind-summary">
        <h3>By Kind</h3>
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,"Critical")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.High,"High")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,"Medium")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Low,"Low")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Info,"Info")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,"Unknown")}
        </div>
        <div className="vuln-component-count-summary">
        <h3>By Component</h3>
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,"Critical")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.High,"High")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,"Medium")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Low,"Low")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Info,"Info")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,"Unknown")}
        </div>
        </Fragment>
    );
  }
}