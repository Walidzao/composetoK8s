<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>WZOPS | Germany DevOps Services</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="WZOPS provides DevOps services across Germany, including CI/CD, Kubernetes, cloud automation, observability, and platform reliability consulting.">
    <link rel="icon" type="image/x-icon" href="${contextPath}/resources/Images/icons/favicon.ico"/>
    <link href="${contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
    <link href="${contextPath}/resources/css/profile.css" rel="stylesheet">
    <link href="${contextPath}/resources/css/wzops-brand.css" rel="stylesheet">
  	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
	<link rel="stylesheet" href="https://bootswatch.com/cosmo/bootstrap.min.css">
	<link rel="stylesheet" href="${contextPath}/resources/css/w3.css">
</head>
<body class="wzops-home">
<div class="container-fluid">
    <nav class="navbar navbar-custom navbar-static-top" role="navigation" style="background-color: #e3f2fd;">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand wzops-brand-link" href="${contextPath}/index">
                    <img class="wzops-brand-mark" src="${contextPath}/resources/Images/branding/wzops-mark.svg" alt="WZOPS logo">
                    <img class="wzops-brand-wordmark" src="${contextPath}/resources/Images/branding/wzops-wordmark.svg" alt="WZOPS">
                </a>
            </div>
            <div class="navbar-collapse collapse">
                <ul class="nav navbar-nav">
                    <li><a href="#technologies">Technologies</a></li>
                    <li><a href="#about">About</a></li>
                    <li><a href="#contact">Contact</a></li>
                    <li><a href="#">Blog</a></li>
                </ul>
                <ul class="nav navbar-nav navbar-right">
                    <li><a href="${contextPath}">Login</a></li>
                    <li><a href="${contextPath}/registration">Sign up</a></li>
                </ul>
            </div>
        </div>
    </nav>
</div>
<!-- Header -->
<header class="w3-display-container w3-content w3-wide" style="max-width:1500px;" id="home">
  <img class="w3-image" src="${contextPath}/resources/Images/dev_img.jpeg" alt="Architecture" width="1500" height="800">
</header>
<div class="w3-content w3-padding-32">
    <blockquote>
        <h2 align="center" style="font-family: Verdana,sans-serif;color:#1C3B47;">WZOPS Germany DevOps Services</h2>
        <h3 align="center" style="font-family: Verdana,sans-serif;color:#1C3B47;">CI/CD, Kubernetes, cloud automation, and platform reliability for modern delivery teams.</h3>
    </blockquote>
</div>
<!-- Page content -->
<div class="w3-content w3-padding" style="max-width:1564px">

  <!-- Project Section -->
  <div class="container w3-padding-32" id="technologies">
    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">TECHNOLOGIES</h3>
  </div>

  <div class="w3-row-padding">
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/Ansible_logo.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
         <img src="${contextPath}/resources/Images/technologies/aws.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/git.jpg" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/jenkins.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
  </div>

  <div class="w3-row-padding">
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/docker.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/puppet.jpg" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/Vagrant.png" alt="DevOps" style="width:150px;height:150px">
      </div>
    </div>
    <div class="w3-col l3 m6 w3-margin-bottom">
      <div class="w3-display-container">
        <img src="${contextPath}/resources/Images/technologies/python-logo.png" alt="DevOps" style="width:200px;height:150px">
      </div>
    </div>
  </div>

  <!-- About Section -->
  <div class="container w3-padding-32" id="about">
    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">ABOUT</h3>
    <div class="w3-content" style="max-width:864px">
	     <p style="text-align:justify;">
                    WZOPS is a Germany-based DevOps consultancy focused on helping engineering teams ship faster with stable, scalable delivery platforms. We design and improve release pipelines, cloud foundations, and operational workflows that support reliable software delivery.
                </p>
                <p style="text-align:justify;">
                    Our services span CI/CD implementation, Kubernetes platform setup, Docker-based application delivery, infrastructure automation, and observability. We work with teams that need a practical path from manual operations to repeatable, production-ready deployment processes.
                </p>
                <p style="text-align:justify;">
                    WZOPS supports platform engineering initiatives across cloud environments, helping organizations standardize infrastructure, improve deployment confidence, and reduce operational friction. We focus on solutions that fit the existing stack without disrupting business-critical delivery.
                </p>
                <p style="text-align:justify;">
                    From build automation and environment consistency to monitoring and release reliability, WZOPS delivers DevOps services that strengthen engineering velocity and production resilience across Germany.
                </p>
                <p><strong>Address:</strong> Germany-wide delivery and consulting services</p>
                <p><strong>Phone:</strong> +49 30 0000 0000</p>
                <p><strong>Email:</strong> contact@wzops.de</p>
  	</div>
   </div>

  <!-- Contact Section -->
  <div class="container w3-padding-32" id="contact">

    <h3 class="w3-border-bottom w3-border-light-grey w3-padding-16" align="center">CONTACT</h3>
    <div class="forms" id="contact-form">
    <p>Talk with WZOPS about Kubernetes delivery, CI/CD modernization, automation, observability, and cloud operations support.</p>
    <p>Use the details above to reach us directly while the contact workflow is being integrated into the platform.</p>
    <form action="#" id="action">
      <input class="w3-input" type="text" placeholder="Name" required name="Name">
      <input class="w3-input w3-section" type="text" placeholder="Email" required name="Email">
      <input class="w3-input w3-section" type="text" placeholder="Service Needed" required name="Subject">
      <input class="w3-input w3-section" type="text" placeholder="Project Scope" required name="Comment">
      <button class="w3-button w3-black w3-section" type="button" disabled title="Contact workflow pending backend integration">
        <i class="fa fa-paper-plane"></i> CONTACT WORKFLOW COMING SOON
      </button>
    </form>
    </div>
  </div>

<!-- End page content -->





</body>
</html>
