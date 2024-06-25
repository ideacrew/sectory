import { Component, ReactNode, Fragment } from "react";
import React from "react";
import * as CycloneModel from "../cyclonedx/models";
import * as cdx from "@cyclonedx/cyclonedx-library";

type PropsType = {
  component: CycloneModel.Component;
  searchValue: string;
};

type StateType = {
  shown: boolean;
}

export class ComponentComponent extends Component<PropsType, StateType, any> {
  constructor(props: PropsType) {
    super(props);
    this.state = {
      shown: false
    };
  }

  toggleShow = () => {
    this.setState((s) => {
      return {...s, shown: !s.shown}
    });
  };

  purlValues() : ReactNode | string {
    if (this.props.component.purl) {
    return <Fragment key={this.props.component["bom-ref"] + "purl"}>
             <dt>PURL</dt>
             <dd>{this.props.component.purl}</dd>
           </Fragment>;
    }
    return "";
  }

  cpeValues() : ReactNode | string {
    if (this.props.component.cpe) {
      return <Fragment key={this.props.component["bom-ref"] + "cpe"}>
              <dt>CPE</dt>
              <dd>{this.props.component.cpe}</dd>
            </Fragment>;
    }
    return "";
  }
  
  vcsValues() : ReactNode[] | string {
    if (this.props.component.externalReferences) {
      const vcsRefs = this.props.component.externalReferences.filter(er => {
        if (er.type === cdx.Enums.ExternalReferenceType.VCS) {
          return true;
        }
        return false;
      });
      if (vcsRefs.length > 0) {
        return vcsRefs.map(vcsr => {
          return <Fragment key={this.props.component["bom-ref"] + vcsr.url}>
            <dt>VCS</dt>
            <dd>{vcsr.url}</dd>
            {this.mapVcsShas(vcsr.hashes)}
          </Fragment>;
        });
      }
    }
    return "";
  }

  mapVcsShas(hashes : CycloneModel.Hash[] | null | undefined) : ReactNode[] | string {
    if (hashes) {
      return hashes.map(h => {
        return <Fragment key={this.props.component["bom-ref"] + "vcs_hash_display" + h.alg}>
          <dt>VCS {h.alg}</dt>
          <dd>{h.content}</dd>
        </Fragment>;
      });
    }
    return "";
  }

  descriptionValues() : ReactNode | string {
    if (this.props.component.description) {
      return <pre>{this.props.component.description}</pre>;
    }
    return "";
  }

  matchClass() {
    let searchVisibility = "";
    if (this.props.searchValue !== "") {
      let didNotMatch = true;
      const searchString = this.props.searchValue.toLowerCase();
      if (this.props.component.name.toLowerCase().indexOf(searchString) > -1) {
        didNotMatch = false;
      }
      if (this.props.component.version) {
        if (this.props.component.version.toLowerCase().indexOf(searchString) > -1) {
          didNotMatch = false;
        }
      }
      if (this.getComponentKind().toLowerCase().indexOf(searchString) > -1) {
        didNotMatch = false;
      }
      if (this.props.component.description) {
        if (this.props.component.description.toLowerCase().indexOf(searchString) > -1) {
          didNotMatch = false;
        }
      }
      if (didNotMatch) {
        searchVisibility = " component-filtered";
      }
    }
    return searchVisibility;
  }

  componentDetailClassName() {
    if (this.state.shown) {
      return "component-detail-row component-detail-shown";
    } else {
      return "component-detail-row component-detail-hidden";
    }
  }

  componentHasVcs() {
    if (this.props.component.externalReferences) {
      const vcsRefs = this.props.component.externalReferences.filter(er => {
        if (er.type === cdx.Enums.ExternalReferenceType.VCS) {
          return true;
        }
        return false;
      });
      if (vcsRefs.length > 0) {
        return true;
      }
    }
    return false;
  }

  componentHasDetails() {
    return this.props.component.cpe || this.props.component.purl || this.componentHasVcs();
  }

  detailsLink() : ReactNode | string {
    if (this.componentHasDetails()) {
      return <td onClick={this.toggleShow} className="table-detail-toggle tac">Details</td>;
    }
    return "";
  }

  getComponentKind() {
    return CycloneModel.getComponentKind(this.props.component);
  }

  public render(): ReactNode {
    const matchClass = this.matchClass();
    return (
      <Fragment>
        <tr key={this.props.component["bom-ref"] + "-mainrow"} className={"component-main-row" + matchClass}>
          <td>{this.props.component.name}</td>
          <td className="tac">{this.props.component.version}</td>
          <td className="tac">{this.getComponentKind()}</td>
          {this.detailsLink()}
        </tr>
        <tr key={this.props.component["bom-ref"] + "-detailrow"} className={this.componentDetailClassName() + matchClass}>
          <td colSpan={4}>
            <dl className="item-summary">
              {this.purlValues()}
              {this.cpeValues()}
              {this.vcsValues()}
            </dl>
            {this.descriptionValues()}
          </td>
        </tr>
      </Fragment>
    );
  }
}