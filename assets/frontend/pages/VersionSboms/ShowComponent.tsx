import { Head, Link } from '@inertiajs/react'
import { MenuComponent } from '../../components/Menu.component'
import { MainSummaryComponent } from "../../components/MainSummary.component"
import { ViewSelectionComponent } from "../../components/ViewSelection.component"
import { useState } from "react";
import { ViewSelection } from '../../components/view_state';
import React from 'react'
import { CycloneDataLoader } from '../../components/cyclone_data_loader';
import "./ShowComponent.css";

export default function ShowComponent({ version_sbom, disallow_analysis }) {
  let [selectedView, changeView] = useState(ViewSelection.COMPONENTS);

  let dataLoader = new CycloneDataLoader(version_sbom.sbom_content.data, disallow_analysis);

  return (
    <>
      <Head title="Version Sbom" />

      <MenuComponent selectedView={selectedView} viewSelector={changeView} />
      <div className="contentArea">
        <MainSummaryComponent dataLoader={dataLoader} />
        <ViewSelectionComponent dataLoader={dataLoader} viewState={selectedView} deliverableVersion={version_sbom.deliverable_version}  />
      </div>
    </>
  )
}