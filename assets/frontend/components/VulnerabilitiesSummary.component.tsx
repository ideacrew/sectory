import { Component, Fragment, ReactNode } from "react";
import { CycloneDataLoader } from "./cyclone_data_loader";
import * as CycloneModel from "../cyclonedx/models";
import * as cdx from "@cyclonedx/cyclonedx-library";
import React from 'react';

type PropsType = {
  dataLoader: CycloneDataLoader;
};

export class VulnerabilitiesSummaryComponent extends Component<PropsType, any, any> {

  countSeverity(sev: cdx.Enums.Vulnerability.Severity, usePossibles: boolean) {
    if (this.props.dataLoader.bom?.vulnerabilities) {
      const vulns = this.props.dataLoader.bom?.vulnerabilities;
      if (vulns.length > 0) {
        const matching = vulns.filter((v) => {
          return CycloneModel.formatSeverity(v) === sev && CycloneModel.isPossibleAssignment(v) === usePossibles;
        });
        return matching.length;
      }
    }
    return 0;
  }

  countComponentSeverity(sev: cdx.Enums.Vulnerability.Severity, usePossibles: boolean) {
    if (this.props.dataLoader.bom?.vulnerabilities) {
      const vulns = this.props.dataLoader.bom?.vulnerabilities;
      if (vulns.length > 0) {
        const matching = vulns.filter((v) => {
          return CycloneModel.formatSeverity(v) === sev && CycloneModel.isPossibleAssignment(v) === usePossibles;
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

  sortVulns(vulns: Array<CycloneModel.Vulnerability>) {
    return vulns.sort((a, b) => {
      return CycloneModel.severitySort(CycloneModel.formatSeverity(b)) - CycloneModel.severitySort(CycloneModel.formatSeverity(a));
    });
  }

  kindSeverityBox(sev: cdx.Enums.Vulnerability.Severity, usePossibles: boolean, label: string) {
    let count = this.countSeverity(sev, usePossibles);
    if (count === 0) {
      return "";
    }
    return <div className={"vuln-severity-box " + "vuln-severity-box-" + label.toLowerCase()}>
             <span className="count">{count}</span>
             <span className="label">{label}</span>
           </div>;
  }

  compSeverityBox(sev: cdx.Enums.Vulnerability.Severity, usePossibles: boolean, label: string) {
    let count = this.countComponentSeverity(sev, usePossibles);
    if (count === 0) {
      return "";
    }
    return <div className={"vuln-severity-box " + "vuln-severity-box-" + label.toLowerCase()}>
             <span className="count">{count}</span>
             <span className="label">{label}</span>
           </div>;
  }

  renderPossibleSummary(hasPossibles: boolean) {
    if (hasPossibles) {
      return <Fragment><div className="vuln-component-kind-summary">
      <h3>Potential Vulnerabilities - By Kind</h3>
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,true, "Critical")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.High,true,"High")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,true,"Medium")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Low,true,"Low")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Info,true,"Info")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.None,true,"None")}
      {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,true,"Unknown")}
      </div>
      <div className="vuln-component-count-summary">
      <h3>Potential Vulnerabilities - By Component</h3>
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,true,"Critical")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.High,true,"High")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,true,"Medium")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Low,true,"Low")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Info,true,"Info")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.None,true,"None")}
      {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,true,"Unknown")}
      </div>
      </Fragment>
    }
    return "";
  }

  hasPossibles() {
    if (this.props.dataLoader.bom?.vulnerabilities) {
      const vulns = this.props.dataLoader.bom?.vulnerabilities;
      if (vulns.length > 0) {
        const matching = vulns.filter((v) => {
          return CycloneModel.isPossibleAssignment(v);
        });
        return matching.length > 0;
      }
    }
    return false;
  }

  public render(): ReactNode {
    let hasPossibles = this.hasPossibles();

    return (
        <Fragment>
        <div className="vuln-component-kind-summary">
        <h3>By Kind</h3>
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,false,"Critical")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.High,false,"High")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,false,"Medium")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Low,false,"Low")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Info,false,"Info")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.None,false,"None")}
        {this.kindSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,false,"Unknown")}
        </div>
        <div className="vuln-component-count-summary">
        <h3>By Component</h3>
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Critical,false,"Critical")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.High,false,"High")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Medium,false,"Medium")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Low,false,"Low")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Info,false,"Info")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.None,false,"None")}
        {this.compSeverityBox(cdx.Enums.Vulnerability.Severity.Unknown,false,"Unknown")}
        </div>
        {this.renderPossibleSummary(hasPossibles)}
        </Fragment>
    );
  }
}