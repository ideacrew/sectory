import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "./cyclone_data_loader";
import * as cdx from "@cyclonedx/cyclonedx-library";
import * as CycloneModel from "../cyclonedx/models";
import React from "react";

type PropsType = {
  dataLoader: CycloneDataLoader;
}

type keyScores = {
  [key in cdx.Enums.Vulnerability.Severity]: number;
}

type ScoreWeight = {
  [key in cdx.Enums.Vulnerability.Severity]: number;
}

type CompScore = keyScores & {
  score: number;
  count: number;
}

const weights : ScoreWeight = {
  critical: 10000,
  high: 200,
  medium: 50,
  low: 10,
  info: 2,
  none: 0,
  unknown: 1
}

type ListEntry = {
  component: CycloneModel.Component;
  scores: CompScore;
}

export class ComponentRiskListComponent extends Component<PropsType, any, any> {
  private scores: Map<string, CompScore> = new Map<string, CompScore>();
  private listItems: Array<ListEntry>;

  constructor(props: PropsType) {
    super(props);
    this.scoreVulns();
  }

  private emptyScore() : CompScore {
    return {
      score: 0,
      count: 0,
      critical: 0,
      high: 0,
      medium: 0,
      low: 0,
      info: 0,
      none: 0,
      unknown: 0
    };
  }

  private scoreVulns() {
    const vulns = this.props.dataLoader.bom?.vulnerabilities;
    if (vulns) {
      if (vulns.length > 0) {
        vulns.forEach((v) => {
          let sev = CycloneModel.formatSeverity(v);
          let affectsList = v.affects;
          if (affectsList) {
            if (affectsList.length > 0) {
              affectsList.forEach((a) => {
                let ref = a.ref;
                if (this.scores.has(ref)) {
                  let curVal = this.scores.get(ref)!;
                  curVal.count = curVal.count + 1;
                  curVal.score = curVal.score + weights[sev];
                  curVal[sev] = curVal[sev] + 1;
                  this.scores.set(ref, curVal);
                } else {
                  let newScore = this.emptyScore();
                  newScore[sev] = 1;
                  newScore.count = 1;
                  newScore.score = weights[sev];
                  this.scores.set(ref, newScore);
                }
              });
            }
          }
        });
      }
    }
    const itemsForSort = new Array<ListEntry>();
    this.scores.forEach((v, k) => {
      const comp = this.props.dataLoader.componentHash.get(k);
      if (comp) {
        itemsForSort.push({
          component: comp,
          scores: v
        });
      }
    });
    this.listItems = itemsForSort.sort((a, b) => b.scores.score - a.scores.score);
  }

  public renderRiskItems() {
    return this.listItems.map((li) => {
      return <tr key={li.component["bom-ref"] + "-vuln-list-item"} className="risk-main-row">
       <td>{li.component.name}</td>
       <td>{li.component.version}</td>
       <td className="tar">{li.scores.score}</td>
       <td className="tar">{li.scores.count}</td>
      </tr>
    })
  }

  public render(): ReactNode {
    return (
      <Fragment>
      <table className="risk-list-table">
        <thead>
          <tr>
            <th className="tal">Component</th>
            <th>Version</th>
            <th>Score</th>
            <th>Vulnerabilities</th>
          </tr>
        </thead>
        <tbody>
          { this.renderRiskItems() }
        </tbody>
      </table>
      </Fragment>
    );
  }
}