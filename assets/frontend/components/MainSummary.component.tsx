import { Component, ReactNode, Fragment } from "react";
import { CycloneDataLoader } from "../data/cyclone_data_loader";
import * as CycloneModel from "../cyclonedx/models";
import * as cdx from "@cyclonedx/cyclonedx-library";
import React from "react";

type PropsType = {
  dataLoader: CycloneDataLoader
};

export class MainSummaryComponent extends Component<PropsType, any, any> {
  private dataLoader : CycloneDataLoader;

  constructor(props: PropsType) {
    super(props);
    this.dataLoader = props.dataLoader;
  }

  vcsValues() : ReactNode[] | string {
    if (this.props.dataLoader.bom?.metadata.component?.externalReferences) {
      const comp = this.props.dataLoader.bom?.metadata.component!;
      const vcsRefs = this.props.dataLoader.bom?.metadata.component?.externalReferences.filter(er => {
        if (er.type === cdx.Enums.ExternalReferenceType.VCS) {
          return true;
        }
        return false;
      });
      if (vcsRefs.length > 0) {
        return vcsRefs.map(vcsr => {
          return <Fragment key={comp["bom-ref"] + vcsr.url}>
            <dt>VCS</dt>
            <dd>{vcsr.url}</dd>
            {this.mapVcsShas(comp, vcsr.hashes)}
          </Fragment>;
        });
      }
    }
    return "";
  }

  mapVcsShas(comp: CycloneModel.Component, hashes : CycloneModel.Hash[] | null | undefined) : ReactNode[] | string {
    if (hashes) {
      return hashes.map(h => {
        return <Fragment key={comp["bom-ref"] + "vcs_hash_display" + h.alg}>
          <dt>VCS {h.alg}</dt>
          <dd>{h.content}</dd>
        </Fragment>;
      });
    }
    return "";
  }

  extractName() : string {
    let name = this.dataLoader.bom?.metadata?.component?.name;
    if (name) {
      return name;
    }
    return "";
  }

  extractVersion() : string {
    let version = this.dataLoader.bom?.metadata?.component?.version;
    if (version) {
      return version;
    }
    return "Unspecified";
  }

  hashRow() : Array<ReactNode> | string {
    let hashes = this.dataLoader.bom?.metadata?.component?.hashes;
    if (hashes) {
      if (hashes.length > 0) {
        let hashRows = hashes.map((h) => {
          return(<tr key={"summary-hash-row-" + h.alg}>
            <td>{h.alg}</td>
            <td>{h.content}</td>
          </tr>);
        })
        return hashRows;
      }
    }
    return ""
  }

  public render(): ReactNode {
    return (
      <div>
        <dl>
          <dt>Name</dt>
          <dd>{ this.extractName() }</dd>
          <dt>Version</dt>
          <dd>{ this.extractVersion() }</dd>
          { this.vcsValues() }
        </dl>
      </div>
    );
  }
}