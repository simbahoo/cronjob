/**
 * Copyright 2016 benjobs
 * <p>
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.jcronjob.controller;

import it.sauronsoftware.cron4j.SchedulingPattern;

import org.jcronjob.base.utils.PageIOUtils;
import org.jcronjob.service.ExecuteService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.quartz.CronExpression;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletResponse;

@Controller
@RequestMapping("/validation")
public class ValidationController {

    private Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    private ExecuteService executeService;

    @RequestMapping("/cronexp")
    public void validateCronExp(Integer cronType, String cronExp, HttpServletResponse response) {
        boolean pass = false;
        if (cronType == 0) pass = SchedulingPattern.validate(cronExp);
        if (cronType == 1) pass = CronExpression.isValidExpression(cronExp);
        PageIOUtils.writeHtml(response, pass ? "success" : "failure");
    }

    @RequestMapping("/ping")
    public void validatePing(String ip, Integer port, String password, HttpServletResponse response) {
        String pass = "failure";
        boolean ping = executeService.ping(ip, port, password);
        if (!ping) {
            logger.error(String.format("validate ip:%s,port:%s cannot ping!", ip, port));
        } else {
            pass = "success";
        }
        PageIOUtils.writeHtml(response, pass);
    }
}
